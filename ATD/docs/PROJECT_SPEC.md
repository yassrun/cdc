# WKF-ATD — Spécifications & Plan de Développement

> **Projet** : Workflow Avis Tiers Détenteur  
> **Équipe** : CDC — CustomerCare  
> **Date** : Mars 2026  
> **TechLead** : En cours

---

## 1. Contexte & Objectifs

### 1.1 C'est quoi un ATD ?

L'**Avis Tiers Détenteur (ATD)** est un acte juridique par lequel des comptables publics
(TGR, CNSS, DGI, Douanes) ordonnent à la banque de **bloquer les comptes** d'un débiteur
et de **saisir les fonds** en remboursement d'une créance.

Le processus implique :
- La création d'un **compte interne** par ATD avec prélèvement des fonds et commissions
- Un **délai réglementaire de J+7** avant exécution du virement
- Une possible **main levée** dans ce délai → restitution des fonds au client
- Un **retour courrier** au demandeur si client négatif ou non-client

### 1.2 Problématique actuelle

Le processus ATD est actuellement traité manuellement par les équipes DSC en
conjonction avec le **Socle RPA**. Face :
- au flux croissant des demandes
- au risque opérationnel lié aux délais réglementaires
- à l'absence de traçabilité et de pilotage centralisé

**Fait confirmé (DP projet)** : l'alimentation du traitement existant se fait par
des **fichiers entrants** transmis au robot **RPA Core Banking**.

La banque souhaite **digitaliser et automatiser** ce processus de bout en bout.

### 1.5 Clarification As-Is

- L'architecture As-Is du cadrage est partiellement ambiguë (zone template).
- Le point fiable à date est le **mode d'entrée fichier -> RPA Core Banking**.
- Toute conception cible doit préserver la continuité de ce canal tant qu'une
     stratégie de remplacement n'est pas validée.

### 1.3 Objectifs du projet

| # | Objectif |
|---|----------|
| 1 | Digitaliser et automatiser le traitement des ATD de bout en bout |
| 2 | Verrouiller le risque opérationnel (respect J+7) |
| 3 | Ajouter plusieurs niveaux de contrôles aux étapes clés |
| 4 | Tracer intégralement le parcours de chaque ATD |
| 5 | Renforcer les contrôles après chaque phase de traitement RPA |
| 6 | Mettre en place un **contrôle 4 yeux** (CTB N1 / CTB N2) |
| 7 | Mettre en place des **KPIs** de suivi |

### 1.4 Périmètre

- **Dans le périmètre** : ATD frappant les personnes physiques (PH) et personnes morales (PM)
- **Hors périmètre** : Clôture des comptes internes, surveillance des ATD (à voir ultérieurement)
- **Règle fondamentale** : 1 ATD = 1 PM ou 1 PH

---

## 2. Acteurs

| Acteur | Rôle |
|--------|------|
| **CTB N1** | Contrôleur de niveau 1 — saisie et correction des dossiers ATD |
| **CTB N2** | Contrôleur de niveau 2 — validation 4 yeux, décisions métier |
| **RPA** | Robot d'automatisation — identification client, exécution virements/restitutions |
| **RÉSEAU** | Agences — réception des notifications de traitement |
| **Admin fonctionnel** | Gestion du référentiel Perception/RIB |

---

## 3. Workflow & Statuts

### 3.1 Machine à états

```
[INITIATION]
     │  CTB N1 soumet
     ▼
[VALIDATION]
     │  CTB N2 valide         CTB N2 rejette → retour [INITIATION]
     ▼
[TRAITEMENT RPA]
     │
     ├──► [CTRL_NEGATIF]
     │         │  CTB N2 confirme négatif        CTB N2 estime positif → retour [INITIATION]
     │         ▼
     │    [A_REMETTRE]  ← statut terminal (ATD NEGATIF)
     │
     └──► [CTRL_POSITIF]
               │  CTB N2 valide ATD              CTB N2 rejette faux positif → [CTRL_NEGATIF]
               │                                 CTB N2 rejette mauvais compte → [INITIATION]
               ▼
          [ATD_EN_ATTENTE]       ← notification agence déclenchée + compteur J+7
               │
               ├──► [ATD_EN_SUSPEND]             ← suspension manuelle CTB N2
               │         │  Levée de suspension → date exécution = J (même jour)
               │         └─────────────────────────────────────────────┐
               │                                                        │
               ├──► [REMISE_MAIN_LEVEE] ← statut terminal              │
               │         │  restitution fonds au client                 │
               │                                                        │
               └──► [ATD_EXECUTEE]  ← virement exécuté à J+7           │◄──┘
                         │  CTB N2 contrôle virement/restitution
                         ▼
                    [ATD_TRAITEE]  ← statut terminal final
```

### 3.2 Règles de gestion par statut

#### INITIATION (CTB N1)
| RG | Description |
|----|-------------|
| RG1 | Saisie des champs réglementaires (voir section 4.1) |
| RG2 | Upload scan ATD en PJ — **optionnel** à cette phase |
| RG3 | Validation → transfert au CTB N2 pour contrôle 4 yeux |
| RG4 | Contrôle anti-doublon sur la REF ATD externe |

Champs obligatoires (combinaisons) :
- Code Client + N° compte
- Nom/Prénom ou Raison Sociale/Sigle + CIN ou RC
- Nom/Prénom ou Raison Sociale/Sigle + N° compte
- Nom/Prénom ou Raison Sociale/Sigle + CIN/RC + N° compte

Champs générés automatiquement :
- **Date ATD** = date de saisie
- **Référence interne** = `ATD + REF_ATD_ETABLISSEMENT + Nom/Prénom`

#### VALIDATION (CTB N2)
| RG | Description |
|----|-------------|
| RG1 | Vérification de tous les champs saisis par CTB N1 |
| RG2 | Possibilité de rejeter (retour CTB N1) **ou** de corriger directement |
| RG3 | Validation → déclenchement du transfert vers le Socle RPA |

#### CONTRÔLE NÉGATIF (CTB N2)
| RG | Description |
|----|-------------|
| RG1 | Le RPA retourne : taux de matching, motif de rejet, capture d'écran Amplitude |
| - | CTB N2 peut modifier le motif de rejet |
| - | CTB N2 peut lancer l'édition du **courrier ATD négatif** |
| - | Si CTB N2 estime faux négatif → rejet → retour CTB N1 pour mise à jour |
| - | Agrégation possible des courriers négatifs par administration/date |
| - | Option : signature dématérialisée sur les courriers |

#### CONTRÔLE POSITIF (CTB N2)
| RG | Description |
|----|-------------|
| RG1 | Le RPA retourne les données du compte (solde, clés, agence, compte interne, montant bloqué, N° lot OD, date exécution) |
| RG2 | ATD avec montant > **200 000** : affichage dans une **couleur différente** |
| RG3 Action 1 | Valider → statut `ATD_EN_ATTENTE` + notification email agence + compteur J+7 |
| RG3 | Si scan ATD manquant → **blocage** de la notification avec message d'erreur |
| RG3 Action 2 | Rejeter faux positif → retour `CTRL_NEGATIF` + restitution fonds (commentaire obligatoire) |
| RG3 | Rejeter mauvais compte → retour CTB N1 au statut initiation |

#### ATD EN ATTENTE (CTB N2)
| RG | Description |
|----|-------------|
| RG4 Action 1 | Suspendre → `ATD_EN_SUSPEND` (en attente décision CTB) |
| RG4 | Levée de suspension → date exécution = J → exécution le jour même |
| RG4 Action 2 | Main levée → `REMISE_MAIN_LEVEE` (terminal) + restitution fonds |

#### CONTRÔLE VIREMENT/RESTITUTION (CTB N2)
| RG | Description |
|----|-------------|
| RG1 | CTB N2 vérifie dans Amplitude que le virement/restitution a bien été exécuté → valide → `ATD_TRAITEE` |
| RG2 | RPA joint une capture d'écran du virement |
| RG3 | CTB N2 peut **forcer** le virement au statut Traité |

---

## 4. Modèle de données (champs ATD)

### 4.1 Champs de saisie
| Champ | Obligatoire | Notes |
|-------|-------------|-------|
| REF ATD Établissement Émetteur | Oui | Anti-doublon |
| Établissement Émetteur | Oui | |
| Montant ATD | Oui | Alerte si > 200K |
| Nom / Raison Sociale | Conditonnel | |
| Prénom / Sigle | Conditionnel | |
| CIN / RC | Conditionnel | |
| N° compte objet de l'ATD | Conditionnel | |
| Code Client | Conditionnel | |
| Date ATD | Auto | Date de saisie |
| Référence interne ATD | Auto | `ATD + REF + Nom` |
| Scan ATD (PJ) | Optionnel saisie / Obligatoire avant notification | Upload fichier |

### 4.2 Champs retour RPA (positif)
| Champ | Source |
|-------|--------|
| Taux de Matching | RPA |
| N° de comptes | RPA |
| Solde des comptes | RPA |
| Clés comptes | RPA |
| Agence comptes | RPA |
| Agence client | RPA |
| Clé compte interne | RPA |
| N° compte interne | RPA |
| Montant bloqué | RPA |
| N° Lot OD | RPA |
| Date d'exécution ATD | RPA |

### 4.3 Référentiel technique à créer
- **Référentiel Perception / RIB** : géré par admin fonctionnel, utilisé pour le virement final

---

## 5. KPIs

| KPI | Description |
|-----|-------------|
| ATD en suspend > 8 jours | Alerte sur dossiers bloqués |
| ATD en suspend (global) | Nombre total de dossiers suspendus |
| ATD au statut "Courrier négatif à remettre" | Dossiers en attente de remise courrier |

---

## 6. Exigences techniques

| # | Exigence |
|---|----------|
| 1 | Import fichier AGIRH **quotidiennement** (détermination agence de notification) |
| 2 | Référentiel Perception/RIB géré par admin fonctionnel |
| 3 | Affichage dynamique des champs obligatoires selon type de saisie |
| 4 | **Batch J+7** : cron qui s'exécute **3 fois par jour** pour identifier les ATD éligibles au virement |
| 5 | Recherche full-text sur tous les champs de saisie |
| 6 | Template courrier négatif avec signature dématérialisée des responsables |
| 7 | Agrégation des courriers négatifs par perception |
| 8 | Gestion d'un flux d'entrée **fichiers vers RPA Core Banking** (format et transport à confirmer) |

---

## 7. Architecture technique

```
Utilisateur BO (CTB N1 / CTB N2 / Admin)
    └──► wkf-atd-front (Angular 21)
              └──► wkf-atd-bff (Spring Boot 3.4.4 / Java 17)
                        ├──► PostgreSQL (schema: workflow-atd)
                        ├──► ms-bpm-client → Socle RPA
                        ├──► API Notification (email agences)
                        ├──► AGIRH (import collaborateurs)
                        ├──► GED / MINIO (scan ATD, courriers)
                        ├──► Keycloak CC (auth utilisateurs BO)
                        └──► Keycloak OC (auth omnicanal)
```

---

## 8. Découpage en phases & sprints

### Phase 0 — Fondations (déjà dans le boilerplate)
> ✅ Déjà livré via le template CDC

- [x] Gestion utilisateurs & rôles
- [x] Gestion référentiel (Filiiales, Agences, UC, DRPP, Délégations)
- [x] Intégration AGIRH
- [x] Sécurité Keycloak / OAuth2
- [x] Infrastructure CI/CD (Jenkins, SonarQube)

---

### Phase 1 — Modèle de données & Workflow core
> **Priorité : CRITIQUE** — Socle de tout le reste

#### BFF
- [ ] Spécifier le contrat d'**ingestion fichiers** As-Is (format, fréquence, source, règles de rejet)
- [ ] Définir la stratégie cible: **conserver**, **encapsuler** ou **remplacer progressivement** le flux fichiers
- [ ] Entité `DossierAtd` (JPA) + migration Flyway `V2`
- [ ] Enum `DossierAtdStatut` (tous les statuts du workflow)
- [ ] `DossierAtdRepository` (Spring Data JPA)
- [ ] `DossierAtdService` (logique métier + transitions)
- [ ] `DossierAtdController` (CRUD + endpoints de transition)
- [ ] Validation anti-doublon sur REF ATD externe (RG4)
- [ ] Génération automatique Référence interne ATD
- [ ] Tests unitaires & d'intégration

#### Frontend
- [ ] Feature module `gestion-atd/`
- [ ] Liste des dossiers ATD (tableau filtrable)
- [ ] Formulaire de saisie CTB N1 (champs dynamiques selon type)
- [ ] Vue détail dossier

---

### Phase 2 — Intégration BPM / RPA
> **Priorité : HAUTE** — Core du flux automatisé

#### BFF
- [ ] Design du BPMN (`template.bpmn`) — cartographie des transitions
- [ ] Intégration `ms-bpm-client` pour déclenchement processus RPA
- [ ] Endpoint de réception des retours RPA (positif / négatif)
- [ ] Stockage captures d'écran RPA (MINIO)
- [ ] Batch J+7 (Cron — 3 executions/jour) pour virement automatique

#### Frontend
- [ ] Vue CTB N2 — Validation 4 yeux
- [ ] Vue CTB N2 — Contrôle négatif (modification motif, édition courrier)
- [ ] Vue CTB N2 — Contrôle positif (données RPA, alerte > 200K)

---

### Phase 3 — Gestion documentaire & Notifications
> **Priorité : HAUTE** — Nécessaire pour la validation CTB N2

#### BFF
- [ ] Upload scan ATD → GED/MINIO
- [ ] Génération courrier ATD négatif (template PDF avec signature dématérialisée)
- [ ] Agrégation courriers par administration/date/perception
- [ ] Notification email agence (OpenFeign → API Notification)
- [ ] Blocage notification si scan manquant

#### Frontend
- [ ] Composant upload PJ
- [ ] Prévisualisation / téléchargement courrier PDF
- [ ] Interface agrégation courriers

---

### Phase 4 — Statuts avancés & Référentiels métier
> **Priorité : MOYENNE**

#### BFF
- [ ] Gestion suspension / levée de suspension (recalcul date exécution)
- [ ] Gestion main levée + restitution fonds
- [ ] Contrôle virement/restitution final (forcer statut Traité)
- [ ] Référentiel **Perception / RIB** (CRUD admin fonctionnel)

#### Frontend
- [ ] Actions suspension / main levée
- [ ] Interface admin — Référentiel Perception/RIB

---

### Phase 5 — Dashboard & KPIs
> **Priorité : MOYENNE**

#### BFF
- [ ] Endpoints statistiques / KPIs agrégés
- [ ] Alertes : ATD en suspend > 8 jours

#### Frontend
- [ ] Dashboard avec widgets KPIs (Chart.js / ng2-charts)
- [ ] ATD en suspend > 8 jours
- [ ] ATD en suspend global
- [ ] ATD au statut "à remettre"

---

### Phase 6 — Recherche & Optimisations
> **Priorité : BASSE**

- [ ] Recherche full-text sur tous les champs de saisie
- [ ] Pagination & filtres avancés
- [ ] Export des listes

---

## 9. Questions ouvertes / Points à clarifier

| # | Question | Responsable |
|---|----------|-------------|
| 1 | Format exact des **fichiers entrants** vers RPA Core Banking (CSV ? TXT ? colonnes, encodage, volumétrie) | OPE / RPA Team |
| 2 | Détail du template BPMN à utiliser avec `ms-bpm-client` | TechLead / AE |
| 3 | Format et contenu exact du template courrier négatif | Métier (Hind Hilmi) |
| 4 | Credentials Keycloak recette à compléter dans le README | Infra (Serraj Taieb) |
| 5 | Définition du référentiel Perception/RIB (structure) | Métier |
| 6 | Heure d'exécution du batch J+7 (3x/jour — à quelle heure ?) | Métier |
| 7 | Règles de rôles Keycloak : qui peut être CTB N1 / CTB N2 / Admin ? | Métier + RSSI |
| 8 | Mode de transport des fichiers (SFTP, dossier partagé, API) et accusé de réception/traçabilité | OPE / Infra |

---

## 10. Staffing & Gouvernance

| Entité | Rôle | Contact |
|--------|------|---------|
| CDC | DP CDC | Omar Loukili |
| OPE | Responsable projet métier | Hind Hilmi |
| AE | Architecte Entreprise | Youssef Chafiki |
| RSSI | Sécurité | Bouamoud Bachir |
| Infrastructure | CP INFRA | Serraj Taieb |
| Infrastructure | Architecture Technique | Youssef Boujjalab |
