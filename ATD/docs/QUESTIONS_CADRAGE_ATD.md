# ATD - Questions de Cadrage a Clarifier

Date: 19/03/2026  
Contexte: atelier de cadrage et decoupage du projet WKF-ATD

## 1. Questions critiques (a trancher en priorite)

| Theme | Question a clarifier | Decision attendue |
|---|---|---|
| As-Is | Le flux actuel demarre par quels fichiers exactement (CSV/TXT/autre) ? | Format officiel d'entree |
| As-Is | Qui depose les fichiers et ou (SFTP, dossier partage, autre) ? | Canal d'ingestion cible |
| As-Is | A quelle frequence arrivent les fichiers et avec quelle volumetrie (moyenne/pic) ? | Hypotheses de capacite |
| As-Is | Quel est le SLA metier entre reception fichier et debut traitement ? | Engagement de delai |
| As-Is | Que fait le robot RPA automatiquement vs CTB N1/N2 manuellement ? | Frontiere d'automatisation |
| Donnees | Quel est le dictionnaire complet du fichier (colonnes, types, encodage, obligatoires) ? | Contrat de donnees valide |
| Donnees | Quelles regles de rejet existent (doublon, champ vide, incoherence) ? | Regles de validation d'entree |
| Donnees | Comment est gere le cas "meme client, plusieurs ATD" ? | Regle d'unicite et d'historique |
| Workflow | La liste finale des statuts ATD est-elle figee ? | Machine a etats officielle |
| Workflow | Quelles transitions exigent un commentaire obligatoire ? | Regles d'audit |
| Workflow | Le seuil > 200K impacte seulement l'affichage ou aussi la validation ? | Regle metier complete |
| J+7 | Le point de depart exact du compteur J+7 est quel evenement ? | Reference temporelle unique |
| J+7 | Le batch J+7 (3 fois/jour) doit tourner a quelles heures ? | Planification technique |
| 4-yeux | Quelles actions sont strictement CTB N1, CTB N2, ou partageables ? | Matrice de roles metier |
| Notifications | Quel evenement declenche l'email reseau et quel contenu est obligatoire ? | Contrat de notification |
| Pieces jointes | A quel moment le scan ATD devient bloquant ? | Regle bloquante/non bloquante |
| Integration | Comment le BFF echange avec le RPA (API, queue, fichier retour, callback) ? | Pattern d'integration |
| Securite | Quelle strategie Keycloak finale (roles, scopes, separation CTB/Admin) ? | Modele d'autorisation |
| Tracabilite | Quelles traces sont obligatoires pour audit (qui, quoi, quand, avant/apres) ? | Exigences de journalisation |
| KPI | Quels KPI sont indispensables au go-live (top 3) ? | Scope KPI lot 1 |

## 2. Questions importantes (a cadrer juste apres)

| Theme | Question a clarifier | Decision attendue |
|---|---|---|
| Courriers | Le template courrier negatif est-il valide juridiquement ? | Version template cible |
| Courriers | Signature dematerialisee: interne ou prestataire, niveau de valeur legale ? | Choix solution signature |
| Referentiel | Qui maintient Perception/RIB et avec quel workflow de validation ? | Gouvernance referentiel |
| AGIRH | Qualite de donnees AGIRH attendue, et que faire en cas d'echec d'import ? | Procedure de rattrapage |
| Exceptions | Comment traiter les dossiers suspendus > 8 jours ? | Workflow d'escalade |
| Reprise | Y a-t-il une reprise de stock historique ATD a migrer ? | Strategie de migration |
| Reporting | Quels exports sont obligatoires (Excel/PDF/API) et pour quels utilisateurs ? | Perimetre reporting |
| Non-fonctionnel | Temps de reponse attendu sur liste/recherche/validation ? | SLO applicatif |
| Non-fonctionnel | Exigences de disponibilite et fenetre de maintenance ? | Niveaux de service |
| Conformite | Duree de retention des pieces et journaux ? | Politique d'archivage |
| Test | Quels scenarios UAT sont bloquants pour la mise en prod ? | Criteres d'acceptation |
| Delivery | Quel decoupage en lots metier (MVP, lot 2, lot 3) ? | Plan de lotissement |

## 3. Questions projet et gouvernance

| Theme | Question a clarifier | Decision attendue |
|---|---|---|
| Priorisation | Quel est le MVP strict pour la mise en production ? | Perimetre lot 1 |
| Dependances | Quelles equipes externes sont critiques (RPA, Infra, Securite, Keycloak, Notification) ? | Carte des dependances |
| Planning | Quelle date cible recette et production ? | Jalons projet |
| Validation | Qui signe le Go/No-Go fonctionnel et technique ? | Gouvernance de decision |
| Risques | Quels risques majeurs suivre des sprint 1 ? | Registre des risques initial |

## 4. Mode d'animation recommande pour le point

1. Commencer par les 20 questions critiques.
2. Marquer chaque question: DECIDE / A INSTRUIRE / BLOQUANT.
3. Finir avec 5 decisions fermes:
   - format des fichiers,
   - mode d'echange RPA,
   - statuts finaux,
   - declencheur J+7,
   - scope MVP.

## 5. Template de compte-rendu rapide

| Question | Decision | Owner | Date cible |
|---|---|---|---|
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
