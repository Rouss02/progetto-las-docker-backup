#!/bin/bash
#
# Script di Backup PostgreSQL Dockerized
# ====
BACKUP_DIR="/backup/postgres"
CONTAINER_NAME="staging_db"
DB_USER="admin"
DB_NAME="app_db"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/db_backup_$DATE.sql.gz"
RETENTION_DAYS=7
echo "[*] Avvio operazione di backup per il database: $DB_NAME ($DATE)"
# Esecuzione del dump e compressione istantanea tramite pipe logica
if docker exec -t $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME | gzip > $BACKUP_FILE; then
    echo "[+] Backup eseguito con successo: $BACKUP_FILE"
else
    echo "[-] ERRORE CRITICO: Fallimento durante il backup del database!" >&2
    exit 1
fi
# Operazione di pruning: pulizia dei backup più vecchi di 7 giorni
echo "[*] Avvio rotazione dei log (Retention: $RETENTION_DAYS giorni)..."
find $BACKUP_DIR -type f -name "*.sql.gz" -mtime +$RETENTION_DAYS -exec rm {} \;
echo "[+] Operazioni concluse con successo."