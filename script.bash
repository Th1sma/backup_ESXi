#!/bin/bash

# Obtenir la date actuelle au format YYYYMMDD
DAYTIME=$(date +"%Y%m%d")

# Fonction pour télécharger un fichier depuis SFTP
download_file() {
    REMOTE_FILE="$1"
    LOCAL_FILE="$2"
    
    echo "--> Téléchargement de $REMOTE_FILE vers $LOCAL_FILE"
    
    # Utiliser sftp pour télécharger le fichier
    sshpass -p "$SFTP_PASSWORD" sftp -o StrictHostKeyChecking=no -P "$SFTP_PORT" "$SFTP_USERNAME@$SFTP_HOST" <<EOF
    get "$REMOTE_FILE" "$LOCAL_FILE"
    bye
EOF
}

# Menu pour entrer les informations de connexion SFTP
echo "== Veuillez entrer les informations de connexion SFTP : =="
read -p "Nom du serveur FTP : " SFTP_HOST
read -p "Port SFTP (par défaut 22) : " SFTP_PORT
read -p "Nom d'utilisateur SFTP : " SFTP_USERNAME
read -s -p "Mot de passe SFTP : " SFTP_PASSWORD
echo

# Menu pour choisir les répertoires
echo "== Veuillez entrer les chemins des répertoires : =="
read -p "Répertoire local pour sauvegarder les fichiers téléchargés : " LOCAL_DIRECTORY
read -p "Répertoire sur le serveur SFTP (fichiers à télécharger) : " SFTP_REMOTE_DIRECTORY
echo

# Télécharger la BDD depuis le serveur SFTP
download_file "$SFTP_REMOTE_DIRECTORY" "$LOCAL_DIRECTORY"

echo "--> Les fichiers sont bien téléchargés."
