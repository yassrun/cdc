# Guide Build BFF - Depuis l'ajout de Maven Wrapper

## Objectif
Rendre le build du BFF executable avec Maven Wrapper (`mvnw`) dans un environnement entreprise avec proxy et Nexus interne.

## Contexte initial
- Le projet BFF ne contenait pas Maven Wrapper.
- `mvn` n'etait pas installe globalement sur la machine.
- Java n'etait pas configure au debut de session.
- Le reseau internet direct vers Maven Central etait bloque.
- Les dependances privees (ex: `com.sgma.ms.bpm:ms-bpm-client`) ne sont pas disponibles sur Maven Central.

## Etapes realisees

### 1. Activation du JDK 17 local
Le JDK local a ete utilise depuis:
- `C:/Users/karkafiy/Desktop/tools/jdk-17.0.18+8`

Verification effectuee:
- `java -version`
- `javac -version`

Resultat attendu:
- Java 17 actif dans la session.

---

### 2. Ajout de Maven Wrapper au projet BFF
Fichiers ajoutes:
- `mvnw`
- `mvnw.cmd`
- `.mvn/wrapper/maven-wrapper.properties`
- `.mvn/wrapper/MavenWrapperDownloader.java`

Configuration principale:
- Distribution Maven 3.9.9
- Wrapper jar 3.3.2

Resultat attendu:
- `./mvnw` et `mvnw.cmd` disponibles dans le repo.

---

### 3. Configuration proxy au niveau projet Maven
Fichiers ajoutes:
- `.mvn/settings.xml`
- `.mvn/maven.config`
- `.mvn/jvm.config`

Parametres appliques:
- Proxy local CNTLM sur `127.0.0.1:3128`
- Activation du settings projet via `-s .mvn/settings.xml`

Resultat attendu:
- Maven utilise le proxy depuis les fichiers du projet (pas besoin de settings global utilisateur).

---

### 4. Demarrage du proxy local CNTLM
CNTLM utilise depuis:
- `C:/Users/karkafiy/Desktop/tools/cntlm-0.94.0`

Fichier de conf detecte:
- `cntlm.ini` (Listen 3128)

Verification effectuee:
- Processus `cntlm` actif
- Port local `3128` en ecoute

Resultat attendu:
- Les appels Maven peuvent sortir via proxy entreprise.

---

### 5. Ajout des repositories Nexus internes
Dans `.mvn/settings.xml`:
- Mirror global vers:
  - `https://nexus-dev.sgmaroc.root.net/repository/maven-public/`
- Repositories declarés:
  - `maven-public`
  - `maven-private`

Pourquoi:
- Les artefacts prives SGMA ne sont pas sur Maven Central.

Resultat attendu:
- Maven tente de resoudre les dependances sur Nexus interne.

---

### 6. Correction TLS/PKIX vers Nexus
Probleme rencontre:
- `PKIX path building failed` sur le host Nexus.

Action:
- Export du certificat serveur Nexus
- Import dans le truststore du JDK local (`cacerts`) avec `keytool`

Resultat attendu:
- Connexion HTTPS Maven -> Nexus acceptee par Java.

---

### 7. Validation finale
Commandes de validation executees:
- `mvnw.cmd -v`
- `mvnw.cmd -DskipTests clean package`

Resultat final:
- Build BFF **SUCCESS**
- Jar genere dans `target/`

---

## Fichiers impactes dans le repo BFF
- `.mvn/maven.config`
- `.mvn/settings.xml`
- `.mvn/jvm.config`
- `.mvn/wrapper/maven-wrapper.properties`
- `.mvn/wrapper/MavenWrapperDownloader.java`
- `mvnw`
- `mvnw.cmd`

## Commande standard a reutiliser
Depuis le dossier BFF:

```powershell
$env:JAVA_HOME="C:/Users/karkafiy/Desktop/tools/jdk-17.0.18+8"
$env:Path="$env:JAVA_HOME/bin;$env:Path"
.\mvnw.cmd -DskipTests clean package
```

## Points d'attention
- Le proxy CNTLM doit etre actif (port 3128).
- Le JDK utilise doit etre celui qui contient le certificat Nexus importe.
- Si le certificat Nexus change, il faudra reimporter le nouveau certificat.
- Si Nexus exige des credentials plus tard, ajouter la section `<servers>` dans `.mvn/settings.xml`.
