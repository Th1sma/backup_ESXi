#!/bin/bash
# FAIRE UN MENU POUR ENTRER LES INFORMATIONS DE CONNEXION SERVEUR / NOM DU DOSSIER OU FICHIER A DOWNLOAD
# Définir les informations de connexion SFTP
SFTP_HOST="name_ftp_server"
SFTP_PORT="22"

# Répertoire local pour sauvegarder les fichiers téléchargés
LOCAL_DIRECTORY=$("find / -type d -name "name_file_research"")

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

# -------------- Téléchargement des fichiers zip depuis le serveur FTP -------------- #
# Suppression de toutes les dossiers / fichiers du repertoire "volume"
# A FAIRE

# Télécharger la BDD depuis le serveur SFTP
download_file "/private/archives/mnails.$DAYTIME.dump.sql.gz" "$LOCAL_DIRECTORY/mnails.$DAYTIME.dump.sql.gz"

# Télécharger les fichiers htdocs depuis le serveur SFTP
download_file "/private/archives/mnails.$DAYTIME.htdocs.zip" "$LOCAL_DIRECTORY/mnails.$DAYTIME.htdocs.zip"

# Décompresser le fichier BDD
decompress_gzip_file "$LOCAL_DIRECTORY/mnails.$DAYTIME.dump.sql.gz" "$LOCAL_DIRECTORY/mnails.$DAYTIME.dump.sql"

# Supprimer le fichier BDD compressé
rm "$LOCAL_DIRECTORY/mnails.$DAYTIME.dump.sql.gz"

# Décompresser le dossier HTDOCS
decompress_zip_file "$LOCAL_DIRECTORY/mnails.$DAYTIME.htdocs.zip" "$LOCAL_DIRECTORY"

# Supprimer le fichier HTDOCS compressé
rm "$LOCAL_DIRECTORY/mnails.$DAYTIME.htdocs.zip"

echo "--> Les dossiers sont bien chargés."

# -------------- Modifications des fichiers de configuration serveur -------------- #
# Chemin vers le fichier de configuration PHP
config_file="$LOCAL_DIRECTORY/htdocs/config/settings.inc.php"

# Nouvelle valeur que vous souhaitez définir
nouvelle_valeur="172.25.0.4"

# Utilisez sed pour modifier la ligne dans le fichier
sed -i "s/define('_DB_SERVER_', '127.0.0.1');/define('_DB_SERVER_', '$nouvelle_valeur');/" /home/master/Bureau/volumes_serveur1/prest_16_test/htdocs/config/settings.inc.php

rm -r  "$LOCAL_DIRECTORY/htdocs/adminold"

echo "--> Les modifications ont été effectuées."

# -------------- Modification des informations sur la BDD -------------- #
# Informations de connexion à la bdd

echo "GRANT ALL PRIVILEGES ON *.* TO 'mnails'@'172.25.0.2' IDENTIFIED BY 'QKKgnie7U31Egg==';" >> "$LOCAL_DIRECTORY/mnails.$DAYTIME.dump.sql"

echo "GRANT ALL PRIVILEGES ON *.* TO 'mnails'@'172.25.0.3' IDENTIFIED BY 'QKKgnie7U31Egg==';" >> "$LOCAL_DIRECTORY/mnails.$DAYTIME.dump.sql"

echo "UPDATE ps_shop_url SET domain='192.168.1.155:7080', domain_ssl='192.168.1.155:7080' WHERE id_shop_url=1;" >> "$LOCAL_DIRECTORY/mnails.$DAYTIME.dump.sql"

echo "--> Modification SQL effectuées."

# -------------- Modification des informations sur la BDD -------------- #
# Modification des permissions sur le conteneur docker presta

nom_conteneur="presta_test_prestashop_1"

#Redémarrage du conteneur
docker restart $nom_conteneur

docker exec -it $nom_conteneur chown -R www-data:www-data /var/www/html

echo "--> Script terminée !"
