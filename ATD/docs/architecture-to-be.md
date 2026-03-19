# Architecture Fonctionnelle & Applicative « TO-BE »

---

## 1. Flux Fonctionnel ATD (atd archi.png)

Diagramme de flux en swimlanes décrivant le processus ATD de bout en bout.

### Acteurs

| Acteur  | Description                        |
|---------|------------------------------------|
| CTB N1  | Contrôleur de niveau 1             |
| CTB N2  | Contrôleur de niveau 2             |
| RPA     | Robot Process Automation           |
| RESEAU  | Réseau / Agences                   |

### Phases du processus

| Phase           | Description                                      |
|-----------------|--------------------------------------------------|
| INITIATION      | Saisie du dossier ATD par CTB N1                 |
| VALIDATION      | Validation par CTB N2                            |
| ATD NEGATIVE    | Contrôle négatif — retour en édition si échec    |
| ATD REJETTE     | Contrôles positifs — sort du flux si rejeté      |
| ATD EN SUSPEND  | Mise en suspension — A Suspendre                 |
| MAIN LEVEE      | Remise en main levée                             |
| ATD EXECUTEE    | Virement ou Restitution exécuté                  |
| TRAITEE         | Ctrl Virement / Restitution final                |

### Étapes détaillées

#### CTB N1
1. **SAISIE** — Initiation du dossier ATD.
2. **A remettre** — En cas de contrôle négatif, le dossier est retourné à CTB N1 pour correction.
3. **Edition** — Édition du dossier avant resoumission.

#### CTB N2
1. **VALIDATION** — Validation du dossier soumis par CTB N1.
2. **CTRL NEGATIF** — Contrôle négatif du dossier.
3. **CTRL POSITIFS** — Contrôle positif du dossier.
4. **SORT** — Décision de tri : suspension ou levée.
5. **Remise Main Levée** — Traitement de la main levée.
6. **A SUSPENDRE** — Mise en attente/suspension du dossier.
7. **CTRL VIREMENT / RESTITUTION** — Contrôle final de l'exécution.

#### RPA
1. **IDENTIFICATION ?** — Vérification automatique d'identification.
   - **Oui** → VALIDE
   - **Non** → retour CTRL NEGATIF
2. **VALIDE** — Dossier validé automatiquement.
3. **Virement** — Exécution du virement.
4. **RESTITUTION** — Exécution de la restitution.
5. **Notification** — Envoi de notification au réseau.

#### RESEAU
- Réception de la **Notification** de fin de traitement.

### Timeline
- **J + 7** : délai maximum de traitement du dossier ATD.

---

## 2. Architecture Applicative ATD (atd archi 2.png)

### ATD : Architecture applicative (TO-BE)

#### Zone : CustomerCare

| Composant    | Technologie | Fonctionnalités                                                              |
|--------------|-------------|------------------------------------------------------------------------------|
| **RPA-front**| Angular     | Gestion des accès, Administration, Principe 4 yeux, Paramétrage, Dashboard  |
| **RPA-DB**   | Base de données | Stockage des données RPA                                                |
| **RPA-BFF**  | Spring Boot | Workflow ATD                                                                 |

#### Zone : API Omnicanal

| Composant            | Description                                      |
|----------------------|--------------------------------------------------|
| **API Notification** | API d'envoi de notifications                     |

#### Zone : SI Production

| Composant     | Description                        |
|---------------|------------------------------------|
| **Socle RPA** | Gestion des robots RPA             |
| **AGIRH**     | Extraction des collaborateurs      |

#### Zone : Service de support

| Composant       | Description                                  |
|-----------------|----------------------------------------------|
| **MINIO**       | Stockage objet (documents, fichiers)         |
| **Keycloak CC** | Gestion des identités CustomerCare           |
| **Keycloak OC** | Gestion des identités Omnicanal              |

#### Utilisateurs
- **Utilisateur BO** : accède à l'application via RPA-front (CustomerCare).

### Flux de communication

```
Utilisateur BO
    └──> RPA-front (Angular)
              ├──> RPA-DB
              └──> RPA-BFF (Workflow ATD)
                        ├──> API Notification (API Omnicanal)
                        ├──> Socle RPA (SI Production)
                        ├──> AGIRH (SI Production)
                        ├──> Keycloak CC (Auth)
                        ├──> Keycloak OC (Auth)
                        └──> MINIO (Stockage)
```
