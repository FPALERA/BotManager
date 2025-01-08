#!/bin/bash

# Créer Anita.sh
cat << 'EOF_ANITA' > /root/Anita.sh
#!/bin/bash
# Demander les informations d'identification
read -p "Entrez les informations d'identification : " creds

# Mettre à jour et installer les paquets nécessaires
sudo apt -y update && sudo apt -y upgrade
sudo apt -y install git ffmpeg curl

# Installer Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
sudo -E bash nodesource_setup.sh
sudo apt-get install -y nodejs
sudo npm install -g yarn
sudo yarn global add pm2

# Demander le nom du bot
read -p "Entrez le nom du bot : " nom
echo "$nom" > nom.txt

# supprimer si existe
rm -rf "/root/BOTWH/$nom"

# Créer le dossier BOTWH/nom
mkdir -p "/root/BOTWH/$nom"

# Copier le répertoire FPBOT dans le nouveau dossier
cp -r FPBOT1 "/root/BOTWH/$nom"

# Supprimer le fichier creds.json s'il existe déjà
rm -f "/root/BOTWH/$nom/FPBOT1/FPBOT/session/creds.json"

# Écrire les informations d'identification dans creds.json
echo "$creds" > "/root/BOTWH/$nom/FPBOT1/FPBOT/session/creds.json"

# Changer de répertoire vers BOTWH/nom/FPBOT
cd "/root/BOTWH/$nom/FPBOT1/FPBOT" || exit

#Installer les dependances 
yarn install

# Trouver le port disponible (3005, 3006, ...)
port=3005
while lsof -i :$port >/dev/null; do
    ((port++))
done

# Démarrer le bot avec pm2 sans logs
PORT=$port pm2 start . --name "$nom"

# Sauvegarder la configuration pm2
pm2 save

# Rendre permanent
pm2 startup

# Revenir à /root
cd /root || exit
EOF_ANITA

# Créer Levanter.sh
cat << 'EOF_LEVANTER' > /root/Levanter.sh
#!/bin/bash

# Demander le nom, l'ID et le numéro
read -p "Entrez le nom : " nom
read -p "Entrez l'ID : " id
read -p "Entrez le numéro(eg 226XXX) : " numero
echo "$nom" > nom.txt

# Mettre à jour et installer les paquets nécessaires
sudo apt -y update && sudo apt -y upgrade
sudo apt -y install git ffmpeg curl

# Installer Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
sudo -E bash nodesource_setup.sh
sudo apt-get install -y nodejs
sudo npm install -g yarn
sudo yarn global add pm2

# Créer le dossier et cloner le dépôt
mkdir /root/Levanter
cd /root/Levanter || exit
rm -rf "$nom"
git clone https://github.com/lyfe00011/levanter "$nom"
cd "$nom" || exit

# Installer les dépendances
yarn install

# Créer le fichier de configuration
cat << EOF_CONFIG > config.env
SESSION_ID = $id
PREFIX = :
STICKER_PACKNAME = LyFE
ALWAYS_ONLINE = false
RMBG_KEY = null
LANGUAG = fr
WARN_LIMIT = 3
FORCE_LOGOUT = false
BRAINSHOP = 159501,6pq8dPiYt7PdqHz3
MAX_UPLOAD = 200
REJECT_CALL = true 
SUDO = $numero 
TZ = Asia/Kolkata
VPS = true
AUTO_STATUS_VIEW = false
SEND_READ = false
AJOIN = true
DISABLE_START_MESSAGE = false
PERSONAL_MESSAGE = null
EOF_CONFIG

# Trouver un port disponible (2000, 2001, ...)
port=2000
while lsof -i :$port >/dev/null; do
    ((port++))
done

# Démarrer le bot avec pm2 sans logs
PORT=$port pm2 start . --name "$nom"

# Sauvegarder la configuration pm2
pm2 save

# Rendre permanent
pm2 startup

# Revenir à /root
cd /root || exit
EOF_LEVANTER

# Créer Bot.sh
cat << 'EOF_BOT' > /root/Bot.sh
#!/bin/bash

# Demande le nom
nom=$(cat nom.txt)

# Demande la durée
echo "Choisissez une durée :"
echo "1. 3 jours"
echo "2. 1 mois"
echo "3. 2 mois"
echo "4. 3 mois"
echo "5. 6 mois"
echo "6. 12 mois"

read -p "Entrez le numéro de votre choix (1-6) : " choix

# Détermine le délai
case $choix in
    1) delai="3 days";;
    2) delai="1 month";;
    3) delai="2 months";;
    4) delai="3 months";;
    5) delai="6 months";;
    6) delai="12 months";;
    *) echo "Choix invalide"; exit 1;;
esac


# Crée le fichier stop_nom.sh
fichier="stop_$nom.sh"
echo "#!/bin/bash" > $fichier
echo "pm2 stop $nom" >> $fichier
echo "pm2 save" >> $fichier

# Donne les permissions d'exécution
chmod +x $fichier

# Calcule la date d'exécution
date_exec=$(date -d "+$delai" '+%M %H %d %m *')

# Vérifie si une tâche cron existe déjà
if crontab -l | grep -q "$fichier"; then
    echo "Une tâche cron existe déjà pour $nom. Mise à jour de la date d'exécution."
    # Supprime l'ancienne tâche
    (crontab -l | grep -v "$fichier") | crontab -
fi

# Ajoute ou met à jour la tâche cron
(crontab -l 2>/dev/null; echo "$date_exec /root/$fichier") | crontab -

echo "Le script $fichier a été créé et ajouté à cron."
rm nom.txt
echo "Le fichier $nom.txt a été supprimé."
EOF_BOT

# Créer manager.sh
cat << 'EOF_MANAGER' > /root/manager.sh
#!/bin/bash
# Nettoyer le terminal
clear

# Fonction pour afficher le texte en couleur arc-en-ciel
rainbow_text() {
    local text="$1"
    local colors=(31 32 33 34 35 36 37) # Couleurs ANSI
    local i=0
    for (( j=0; j<${#text}; j++ )); do
        printf "\e[${colors[i]}m${text:j:1}\e[0m"
        ((i=(i+1)%${#colors[@]})) # Passer à la couleur suivante
    done
    echo # Nouvelle ligne à la fin
}

# Afficher l'en-tête avec art ASCII en couleur arc-en-ciel
echo "========================================"
rainbow_text "          By FPALERA 😎 || 22658179319               "
echo "========================================"

# Fonction pour afficher les processus pm2
afficher_pm2() {
    echo "Processus gérés par pm2 :"
    pm2 list
}

# Fonction pour afficher les tâches cron
afficher_cron() {
    echo "Tâches cron existantes :"
    crontab -l || echo "Aucune tâche cron trouvée."
}

# Fonction pour démarrer Bot.sh
demarrer_bot() {
    # Passer le nom en argument à Bot.sh
    bash /root/Bot.sh "$1"
}

# Menu principal
echo "Bienvenue dans le gestionnaire de bots."
echo "1. Installer Anita"
echo "2. Installer Levanter"
echo "3. Afficher les bots"
echo "4. Afficher les tâches cron"
echo "5. vider les inactifs"
echo "6. Mettre à jour le script"
echo "7. Desinstaller le script"
echo "8. Quitter"

# Boucle jusqu'à ce que l'utilisateur choisisse de quitter
while true; do
    read -p "Choisissez une option (1-8) : " choix

    case $choix in
        1)
            echo "Installation d'Anita..."
            # Appeler le script Anita.sh
            bash /root/Anita.sh
            # Démarrer Bot.sh avec le nom
            demarrer_bot "$nom"
            ;;
        2)
            echo "Installation de Levanter..."
            # Appeler le script Levanter.sh
            bash /root/Levanter.sh
            # Démarrer Bot.sh avec le nom
            demarrer_bot "$nom"
            ;;
        3)
            afficher_pm2
            ;;
        4)
            afficher_cron
            ;;
        5)
            pm2 delete --silent $(pm2 list | grep 'stopped' | awk '{print $2}')
            ;;
        6)
            rm /root/manager.sh && rm /root/Anita.sh && rm /root/Levanter.sh && rm /root/Bot.sh && rm /root/installer.sh && rm -rf /root/FPBOT1
            git clone https://github.com/FPALERA/BotManager/ /root/FPBOT1 && cd /root/FPBOT1 && unzip FPBOT.zip && cp installer.sh /root && cd /root && chmod +x installer.sh && ./installer.sh
            echo "Le script a été mis à jour !"
            ;;
        7)
            rm /root/manager.sh && rm /root/Anita.sh && rm /root/Levanter.sh && rm /root/Bot.sh && rm /root/installer.sh && rm -rf /root/FPBOT1
            echo "Au revoir !"
            ;;
        8)
            echo "Au revoir !"

           exit 0
            ;;
        *)
            echo "Choix invalide, veuillez réessayer."
            ;;
    esac
done
EOF_MANAGER

# Créer menu.sh
cat << 'EOF_MENU' > /root/menu.sh
#!/bin/bash
echo 'alias manager="bash /root/manager.sh"' >> ~/.bashrc && source ~/.bashrc && manager
EOF_MENU

# Rendre les scripts exécutables
chmod +x /root/Anita.sh /root/Levanter.sh /root/Bot.sh /root/manager.sh

echo "Le gestionnaire de bots a été installé avec succès."

