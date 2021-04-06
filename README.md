# gestion_stock_server

# Installation
## -  Installation du sdk dart
Premierement telecharger le fichier zip dart 2.7 et extraire dans un repertoir absolu  xxx
```bash
cd xxx
wget https://storage.googleapis.com/dart-archive/channels/stable/release/2.7.2/sdk/dartsdk-linux-x64-release.zip
##################
# NB si wget n'existe pas,  utiliser  curl
# curl  https://storage.googleapis.com/dart-archive/channels/stable/release/2.7.2/sdk/dartsdk-linux-x64-release.zip  --output dartsdk-linux-x64-release.zip
#################################

# extraction du fichier telecharger
unzip dartsdk-linux-x64-release.zip

# ajouter dart dans les path du system 
echo export PATH='"$PATH":"'"$PWD"/dart-sdk/bin'"' >> ~/.bashrc
echo export PATH='"$PATH":"$HOME/.pub-cache/bin"' >> ~/.bashrc
# rechargement des modifications dans le terminal  courant
source ~/.bashrc
```
## - Installer  le framework aqueduct
```bash
# activation d'aqueduct
pub global activate aqueduct
# naviguer dans le repertoir root du projet server
cd ${gestiontock.server.root}
# installer les dependances
pub get
```

## - Creer la base de donnee
Aqueduct utlise principalement postgres comme sgbd donc il  faudra installer postgres dans la machine  cible.  suivre  ce  tutoriel
[installation de postgres et restauration d'une  base de donnee](https://www.postgresqltutorial.com/install-postgresql-linux/)

### * creation des identifiant
Nous avons besoin d'une   base de  donnee et utilisateur plus mot de passe ayant tout les droits dans cette  base de  donnee. pour ce faire  suivre  [ce tuto](https://www.cyberciti.biz/faq/howto-add-postgresql-user-account/)

## - Verification des informations et migration
Une fois notre nouvelle base de donnee cree, toujour dans le repertoire root  du projet, verifier l'existance des fichier  config.yaml  et databse.yaml. si ces dernier n'existe pas, leur creer par copie respectif  des fichier  default.config.yaml  et default.databse.yaml
```bash
cp default.databse.yaml databse.yaml && cp default.config.yaml config.yaml
```
verifier le  contenu de ces fichiers et mettre ajout les identifiant de la base de donnee. 

**finalement, effectuer une migration**
```bash
# if this is a new project, run db generate first
aqueduct db upgrade
```
## - Lancer l'application
```bash
aqueduct serve -p ${your.prefered.port}
#demarer le server en arriere  plan
nohup aqueduct serve ${your.prefered.port} > ./server_log.log 2>&1 &
# verifier que le server a bien demarer
tail  -50 ./server_log.log
#############################################
# NB: ne pas oublier de remplacer ${your.prefered.port} par le  port utiliser dans fichier [lib/link] du repertoire root de l'application  mobile en occurence le  port 8083
############################################
```

## Deploying an Application
Pour plus d'information sur le deploiment des applications aqueduct,
See the documentation for [Deployment](https://aqueduct.io/docs/deploy/).


