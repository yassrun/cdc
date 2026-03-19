




WORKFLOW AVIS TIERS DETENTEUR

Dossier de Cadrage




Version du document
Version	Date	Nom	Modifications effectuées
V1.0	19/01/2026	Omar	 Initiation du document
			
 
SOMMAIRE
1	OBJET DU DOSSIER DE CADRAGE	4
2	APERÇU GENERAL DU PROJET	5
2.1	BESOIN ET OBJECTIFS	5
2.2	PERIMETRES	6
2.3	HORS PERIMETRE	7
2.4	PROJETS CONNEXES	7
2.5	ELIGIBILITE AU CNP – COMITE NOUVEAU PRODUIT	7
3	CADRAGE FONCTIONNEL	8
3.1	OBJET DU CADRAGE FONCTIONNEL	8
3.2	MACRO-PROCESSUS DE NOTATION DES CONTREPARTIES CORPO	8
3.3	PROCESSUS DE NOTATION DERIVEE (PND)	10
3.4	PROCESSUS DE NOTATION EN STANDALONE (PNC, PNE ET PSR)	11
3.5	PROCESSUS DE PROROGATION	13
3.6	PROCESSUS DE NOTATION DE CONTREPARTIE EN DEFAUT (ENTREE, CONTAGION ET RENOUVELLEMENT)	13
3.7	PROCESSUS D’ENTREE/SORTIE DES SENSIBLES	15
3.8	PROCESSUS VOITURE BALAI	17
3.9	LES MODELES DE NOTATION	19
4	CADRAGE TECHNIQUE	22
4.1	DESCRIPTION DE LA SOLUTION	22
4.2	IMPACTS MACRO ARCHITECTURES ET SI	22
4.2.1	Architecture As-Is	22
4.2.2	Architecture To-Be	25
4.2	IMPACTS SECURITE	25
5	ÉVALUATION DES COUTS (BUSINESS CASE)	26
6	SOLUTIONS NON RETENUES	27
7	EXIGENCES, CONTRAINTES ET RISQUES	28
7.1	EXIGENCES ARCHITECTURE TECHNIQUE	28
7.2	EXIGENCES ARCHITECTURE ENTREPRISE	28
7.3	EXIGENCES SECURITE	28
8	PLANNING ET PLAN DE CHARGES	29
8.1	PLANNING ET DESCRIPTION DES ACTIVITES	29
8.1.1	Planning de cadrage	29
8.2	ESTIMATION DES CHARGES	29
8.3	COMITOLOGIE	30
8.4	GOUVERNANCE	31
8.5	STAFFING PREVISIONNEL	31
9	ANNEXES	33
9.1	REFERENCE DU DOCUMENT	33

 
 
1	OBJET DU DOSSIER DE CADRAGE
Le présent document constitue le dossier de cadrage. 

Il présente la solution qui va être mise en place et réunit les éléments nécessaires à une prise de décision sur le lancement ou non d’un projet en évaluant, à l’issue d’une première analyse, les bénéfices, les coûts et les risques liés au besoin et à la solution bancaire envisagée.

2	APERÇU GENERAL DU PROJET
2.1	Besoin et objectifs :

Les comptables publics (Trésorerie générale du Royaume (TGR), La Caisse nationale de sécurité sociale (CNSS), La Direction générale des impôts (DGI), Douanes) recouvrent les créances auprès de débiteurs indélicats.
L’Avis Tiers Détenteur habilite le recouvreur public à faire bloquer par la banque les comptes des débiteurs et à saisir les sommes qui s’y trouvent en remboursement des montants à recouvrer.    

Pour un même client, une demande de renseignement peut se transformer en ATD, la DSC a besoin de garder un historique consolidé des différentes demandes (de la demande de renseignement au dénouement de l’ATD). De ce fait l’enclenchement du process ATD se fait suite à la réception d’un nouveau fichier ATD / demande papier émis par l’administration en question et se déroule comme suit :

-	Création de compte interne par ATD (par client) et prélèvement des fonds et commissions.
-	Le compte interne reste en suspens pendant 7 jours avant d’enclencher le process de prélèvement qui se fait via OD.
-	Si une main levée est présentée dans le délai de ces 7 jours, les fonds sont reversés sur le compte du client
-	Retour au demandeur de l’ATD uniquement si client ne permet pas de prélèvement ou si l’individu n’est pas client, le retour se fait par courrier.

Le Avis Tiers Détenteurs son actuellement traités par les équipes DSC en conjonction avec le RPA. 

Ceci a permis de garantir les traitements de masse provenant des différentes administrations. Il s’agit d’un processus qui engage la banque en cas de traitement non conforme ou hors délais.

Face au flux croissant des demandes et suite à la requête métier où il a été demandé d’accroitre la sécurisation du processus, verrouiller le risque opérationnel et d’ajouter une couche de pilotage.

Les principaux objectifs sont : 

•	Digitaliser et automatiser le traitement des ATD de bout en bout.
•	Verrouiller le risque opérationnel.
•	Ajouter plusieurs niveaux de contrôles dans les étapes clé du processus.
•	Tracer intégralement le parcours des ATD. 
•	Renforcer les contrôles après chaque phase clé après traitement RPA.
•	Ajouter un contrôle quatre Yeux.
•	Mettre en place des KPI

2.2	Périmètres 
Les ATD frappant les personnes physiques ainsi que les personnes morales.

2.3	Hors périmètre

Préciser ce que le projet ne fait pas, ce qui ne sera pas pris en compte dans la solution, pour éviter les malentendus. 


2.4	Projets connexes
Voici les adhérences de ce projet avec les autres projets en cours :
-	Le projet RPA ATD qui est actuellement en productuion et qui sera fusionné avec la nouvelle solution cible. 
2.5	Eligibilité au CNP – Comité Nouveau Produit

Non éligible au CNP.

3	CADRAGE FONCTIONNEL
3.1	Objet du cadrage fonctionnel
La présente section a pour objet de décrire les processus métier créés/affectés par le projet ainsi que les exigences fonctionnelles, de performance et de sécurité d’un point de vue métier. Le remplissage de cette partie est sous la responsabilité du métier.
Il est primordial de trier les besoins exprimés suivant leur degré de priorité et s’efforcer de décrire des besoins comparables (même niveau de besoin). Ce découpage doit partir du macroscopique vers le spécifique ce qui permettra de faciliter le lotissement, la conception et la réalisation future du projet.

Le cadrage fonctionnel ne doit pas engendrer une expression de besoins mais une liste de macro-processus. L’expression de besoins détaillés au sens de la description des processus et des règles de gestion associées doit intervenir au maximum en phase de conception.

 










Ci-dessous la description détaillé e du processus métier implémenté dans la cible avec les différentes règles de gestion par phase de traitement :


RG0 : 1 ATD = 1 PM ou PH


Statut initiation

RG1 : le CTB N1 procédera à la saisie de l'ensemble des champs nécessaire pour une ATD unitaire

REF ATD Etablissement Emetteur
ETABLISSEMENT EMETTEUR
Montant ATD
Nom OU Raison social
Prénom OU Sigle
CIN ou RC
Numéro de compte objet de l’ATD
Code Client

Les champs obligatoires suivront les combinaisons suivantes :

•	Code Client + Numéro de compte objet de l’ATD
•	Nom/Prénom ou Raison Sociale/Sigle + CIN ou RC
•	Nom/Prénom ou Raison Sociale/Sigle + Numéro de compte objet de l’ATD
•	Nom/Prénom ou Raison Sociale/Sigle + CIN ou RC + Numéro de compte objet de l’ATD

Les Champs Suivants seront générés automatiquement :

•	Date ATD :  il s’agira de la date du jour de la saisie
•	Référence Interne de l’ATD : « ATD + REF ATD ETABLISSEMENT Emetteur + Nom/Prénom »


RG 2 : En plus de la saisie de l'ensemble des champs le CTB N1 devra uploader en pièce jointe le scan de l’ATD. N’est pas obligatoire lors de cette phase.

RG 3 : Une fois l'ensemble des champs renseignés par le CTB N1 la validation de la saisie transférera le dossier ATD au CTB N2 pour Validation quatre Yeux.

RG 4 :  L’applicatif contrôle si les référence ATD externe sont en double.

Statut validation :

RG1 : CTB N2 procédera à la vérification que tous les champs qui ont été précédemment saisis par le CTB N1 sont corrects.

RG2 : si une anomalie et détecter au niveau de la saisie le CTB N2 aura la possibilité soit de rejeter le dossier au CTB N1 soit de procéder lui-même à la correction de l'ATD.

RG3 : Une fois que la vérification des champs et terminée, le CTB N2 procédera à la validation du dossier. Ce qui va déclencher le transfert du dossier ATD RPA

Traitement RPA :

Statut CONTOLE NEGATIF 

RG1 : Suite à la phase de recherche du client par le robot, Cas un client négatif
Le robot va retourner au niveau du workflow le fait que la personne physique ou morale en question est négatif. Dans ce retour le robot, une capture d’écran d’amplitude (si possible) et préciser le motif de rejet. 

La structure des champs affichés sera la suivante :
REF ATD Etablissement Emetteur
ETABLISSEMENT EMETTEUR
Montant ATD
Nom OU Raison social
Prénom OU Sigle
CIN ou RC
Numéro de compte objet de l’ATD
Code Client
Date ATD
Taux de Matching
Motif De Rejet

•	Le CTB N2 va procéder aux contrôles des personnes morales et physiques dont le statut est négatif. Lors de cette phase de contrôle le CTB N2 on aura la possibilité de modifier le motif de rejet.

•	Le CTB N2 pourra ensuite lancer l'édition du courrier de l’ATD négatif.

•	Dans le cas ou CTB N2 estime qu'il s'agit d'un positif, le dossier sera rejeté et renvoyé au CTB N1 pour mise à jour.


•	Avoir la possibilité d’agréger les courriers négatifs par administration/Date

•	Avoir la possibilité d’ajouter la signature dématérialisée




Statut A remettre 

•	Le CTB1 devra saisir la date de remise du courrier négatif à l’administration 

•	Il s'agit là d'un statut terminal du workflow. « ATD NEGATIF »


Statut CONTOLE POSITIF 

RG1 : Suite à la phase de recherche du client par le robot, Cas un client positif 
•	Dans le cas d'un positif, le CTB N2 procédera aux contrôles des données de l’ATD mis à disposition au Niveau du workflow :

REF ATD Etablissement Emetteur	Numéro de comptes
ETABLISSEMENT EMETTEUR	Solde des comptes
Montant ATD	Clés Comptes
Nom OU Raison social	Agence Comptes
Prénom OU Sigle	Agence Client
CIN ou RC	Clé Compte Interne
Numéro de compte objet de l’ATD	Numéro compte interne
Code Client	Montant Bloque
Date ATD	Numéro Lot OD
Taux de Matching	Date D'exécution ATD
REF INTERNE ATD	

RG2 : Les ATD dont le montant est supérieur 200K seront affichées d’une couleur différente

RG3 : Suite au contrôles effectuées par le CTB N2, 2 actions seront possibles.

	Action 1 : Valider l’ATD, le workflow passera au statut « ATD EN ATTENTE » 
o	Une notation par email sera envoyée à l’agence automatiquement, contenant un récapitulatif de de l’ATD ainsi que le scan de l’ATD. 
o	Si le dossier de l’ATD ne comprend pas le scan de l’ATD en pièce jointe, cela bloquera l’envois de la notification au réseau et un message d’erreur s’affichera.
o	Le compteur sera déclenché pour que l’exécution du virement à l’administration concernée ai lieu à J+7. 
o	A « J+7 » le virement sera exécuté et le workflow passera au statut « ATD EXECUTEE »

	Action 2 : Rejeter l’ATD :
o	Si Faux positif >> le rejet entraine le retour de l’ATD vers le statut « Contrôle NEGATIF » et la restitution des fonds. Cette action nécessitera la saisie d’un commentaire obligatoire.
o	Dans le cas où le prélèvement n’a pas été effectué sur le bon compte l’ATD sera retourné au CTB N1 au statut initiation 
RG4 : Une fois que l’ATD au statut « ATD EN ATTENTE », le CTB N2 aura 2 actions seront possibles.

	Action 1 : Mettre l’ATD en état de suspension, le workflow passera au statut « ATD EN SUSPEND ». Il ne sera pas pris en charge jusqu’à nouvelle décision du CTB.
Dans le cas où la suspension est levée, il faudra modifier le champ date d’exécution à « J ». Et l’ATD devra être exécutée le jour même.

	Action 2 : Mettre l’ATD en état de main levée, le workflow passera au statut « REMISE MAIN LEVEE». 
Il s'agit là d'un statut terminal du workflow. 
Ceci déclenchera la restitution des fonds au client.

Statut CONTOLE VIREMENT/RESTITUION 

RG1 : Suite à l’exécution du virement ou de la restitution au client, le CTB N2 procédera aux vérifications au niveau d’amplitude pour s’assurer que les opérations précédemment citées ont bien traitées et procédera à la validation de ce contrôle qui poussera l’ATD au statut final « ATD TRAITEE ».

RG2 : Le RPA joindra une capture d’écran du virement au niveau du workflow

RG3 : LE CTB N2 aura la possibilité de forcer le virement au statu « Traité »

PROPOSITION DE KPI :

	ATD en suspend > 8 jours
	ATD en suspend globaux
	ATD au statut à Courrier négatif remettre à l’administration

A voir ultérieurement :
•	Intégrer la Clôture des comptes internes
•	Surveillance des ATD

RG TECHNIQUES :

•	Intégration du fichier Agirh quotidiennement pour déterminer à quelle agence sera envoyée la notification client
•	Mis en place d’un référentiel « Perception / RIB », qui sera utilisé pour l’exécution du virement en fin de processus et qui sera géré par un administrateur fonctionnel métier.
•	Sélection du type de saisie et affichage des champs obligatoires de façon dynamique 
•	Pièce jointe du scan de l’ATD est optionnel à la saisie.
•	Mise en place d’un Template pour les courriers négatifs incluant la signature des responsables
•	Agrégation des courriers par perception
•	Offrir la possibilité d’effectuer des recherches en se basant sur tous champs qui ont servi à la saisie 
•	Mise en place Cron table pour déterminer les ATD éligible à l’envoi du virement à J+7.Ce batch devra s’exécuter 3 fois par jour.
4	CADRAGE TECHNIQUE
4.1	Description de la solution

Décrire (quand le projet s’y prête) 2 solutions et les impacts ci-après : une solution complète et une solution « dégradée ». 

4.2	Impacts macro architectures et SI
4.2.1	Architecture As-Is
Actuellement, la notation des contreparties sensibles Copro et la gestion des contreparties sensibles sont gérées dans deux solutions groupe distinctes (NOVA et WATCHLIST) dont les architectures As-Is sont les suivantes :

	Architecture AS IS :





 


4.2.2	Architecture To-Be

 
4.2	Impacts Sécurité 
 

En cas de doute, se référer à la Cartographie applicative COO

-	

5	ÉVALUATION DES COUTS (BUSINESS CASE)

Déterminez le coût global des 2 solutions. Voir template ci-dessous :

 

6	SOLUTIONS NON RETENUES

Expliquer les autres solutions envisagées et non retenues, avec la raison.
7	EXIGENCES, CONTRAINTES ET RISQUES

7.1	Exigences Architecture Technique




7.2	Exigences Architecture Entreprise




7.3	Exigences Sécurité



8	PLANNING ET PLAN DE CHARGES
8.1	Planning et description des activités
8.1.1	Planning de cadrage
 

8.2	Estimation des charges
	L’estimation des charges est nécessaire pour passage en COPRO de fin de cadrage 
	L’estimation des charges est nécessaire pour chaque lot constituant le projet

Exemple de calcul des charges :

•	Elle se fait en fonction des activités à mettre en place pour atteindre les objectifs du projet
•	Dans un premier temps il faut déterminer les livrables par phase projet
•	Ensuite la charge associée à ces livrables est estimée suivant le nombre de jour/Homme nécessaire à leur réalisation et au Cash out que cela implique
•	Il est souvent nécessaire de faire appel à des experts métiers afin d’estimer le niveau de complexité de certaines activité

Voir exemple ci-dessous

Phase projet	Livrable	Cash Out	Charge JH
CADRAGE	Dossier de cadrage (DP/ TL ext) 
	16	14
CADRAGE	Support CAST ( Initiation DAT , DS , DEX ) 
(DP Int./ TL ext.)
	16	9
			
			
			
			
			
			
			
			
			
			
			
			
			
		

	Vérifier que tous les activités du projet sont estimées.
	Une bonne pratique est d’estimer les charges pour chaque chantier, de globaliser par lot puis au niveau du projet

8.3	Comitologie
Ce projet s’intègre dans le chantier GASPARD et suit la même comitologie que celui-ci.
 

8.4	Gouvernance


8.5	Staffing prévisionnel

Entité	Responsabilité	Contact
CDC	DP CDC	Omar Loukili
OPE	Responsable du projet métier	Hind hilmi
AE	Architecte Entreprise	Youssef Chafiki
RSSI	Sécurité	Bouamoud bachir
Infrastructure	CP INFRA	Serraj Taieb
Infrastructure	Architecture Technique	Youssef Boujjalab


9	ANNEXES

9.1	Référence du document
Titre 	Dossier de cadrage
Processus	Processus général – Phase de Cadrage
Template	TPL14
Responsable du contenu :	  

Référence du document :	

Nom du fichier : 	

Rédaction du document
Entité/ Service/Fonction	Date	Nom
		
		

Validation du document
Organisation/Fonction	Date	Nom
	 	 
		

Diffusion du document
Organisation/Fonction	Date	Nom
		
		

Commentaires


