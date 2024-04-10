mkdir /vmfs/volumes/datastore1/ESXi_backup

# Synchronisation de la configuration firmware de l'hôte ESXi
vim-cmd hostsvc/firmware/sync_config

# Création d'une sauvegarde de la configuration de l'hôte ESXi
vim-cmd hostsvc/firmware/backup_config

# Recherche des fichiers avec l'extension .tgz dans le répertoire /scratch/downloads/
# et les copie vers le répertoire /vmfs/volumes/datastore1/ESXi_backup/ en les renommant avec la date et l'heure actuelles
find /scratch/downloads/ -name "*.tgz" -exec cp {} /vmfs/volumes/datastore1/ESXi_backup/ESXi_config_backup_$(date +'%Y%m%d_%H%M%S').tgz \;
