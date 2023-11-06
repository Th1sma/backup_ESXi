#!/bin/bash

# Menu pour entrer les informations de connexion SFTP
echo "Veuillez entrer les informations de connexion SFTP :"
read -p "Nom du serveur FTP : " SFTP_HOST
read -p "Port SFTP (par défaut 22) : " SFTP_PORT
read -p "Nom d'utilisateur SFTP : " SFTP_USERNAME
read -s -p "Mot de passe SFTP : " SFTP_PASSWORD
echo

# Menu pour choisir les répertoires
echo "Veuillez entrer les chemins des répertoires :"
read -p "Répertoire local pour sauvegarder les fichiers téléchargés : " LOCAL_DIRECTORY
read -p "Répertoire sur le serveur SFTP : " SFTP_REMOTE_DIRECTORY
echo

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

# Fonction pour décompresser un fichier gzip
decompress_gzip_file() {
    GZIPPED_FILE="$1"
    DECOMPRESSED_FILE="$2"
    
    echo "--> Décompression de $GZIPPED_FILE vers $DECOMPRESSED_FILE"
    
    # Utiliser gzip pour décompresser le fichier
    gunzip -c "$GZIPPED_FILE" > "$DECOMPRESSED_FILE"
}

# Fonction pour décompresser un fichier zip
decompress_zip_file() {
    ZIP_FILE="$1"
    DESTINATION_DIRECTORY="$2"
    
    echo "--> Décompression de $ZIP_FILE vers $DESTINATION_DIRECTORY"
    
    # Utiliser unzip pour décompresser le fichier zip
    unzip "$ZIP_FILE" -d "$DESTINATION_DIRECTORY"
}

# -------------- Téléchargement des fichiers depuis le serveur FTP -------------- #
# Télécharger la BDD depuis le serveur SFTP
download_file "$SFTP_REMOTE_DIRECTORY/mnails.$DAYTIME.dump.sql.gz" "$LOCAL_DIRECTORY/mnails.$DAYTIME.dump.sql.gz"

# Télécharger les fichiers htdocs depuis le serveur SFTP
download_file "$SFTP_REMOTE_DIRECTORY/mnails.$DAYTIME.htdocs.zip" "$LOCAL_DIRECTORY/mnails.$DAYTIME.htdocs.zip"

# Décompresser le fichier BDD
decompress_gzip_file "$LOCAL_DIRECTORY/mnails.$DAYTIME.dump.sql.gz" "$LOCAL_DIRECTORY/mnails.$DAYTIME.dump.sql"

# Supprimer le fichier BDD compressé
rm "$LOCAL_DIRECTORY/mnails.$DAYTIME.dump.sql.gz"

# Décompresser le dossier HTDOCS
decompress_zip_file "$LOCAL_DIRECTORY/mnails.$DAYTIME.htdocs.zip" "$LOCAL_DIRECTORY"

# Supprimer le fichier HTDOCS compressé
rm "$LOCAL_DIRECTORY/mnails.$DAYTIME.htdocs.zip"

echo "--> Les fichiers sont bien téléchargés et décompressés."
