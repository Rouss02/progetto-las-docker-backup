# 🐳 Docker Staging Environment & Automated Backup System

Questo progetto illustra la configurazione di un ambiente di staging basato su **Docker** e l'implementazione di un sistema di disaster recovery automatizzato su ambiente **Linux (Ubuntu Server 22.04 LTS)**. 

Il progetto è stato sviluppato come case-study accademico per il corso di *Laboratorio di Amministrazione di Sistema*.

## 🎯 Obiettivi del Progetto
*   **Isolamento e Riproducibilità:** Abbandono dell'approccio monolitico in favore di un'architettura a container per l'ambiente di staging.
*   **High Availability:** Configurazione di policy di riavvio automatico per i servizi critici.
*   **Sicurezza dei Dati:** Implementazione di un sistema di backup logico, automatizzato e con logica di *retention* per proteggere i dati persistenti da guasti o errori umani.

## 🛠️ Tecnologie Utilizzate
*   **Docker & Docker Compose:** Virtualizzazione a livello di OS e orchestrazione dei container.
*   **Nginx (Alpine):** Web server/Reverse Proxy leggero.
*   **PostgreSQL (Alpine):** RDBMS per la memorizzazione dei dati.
*   **Bash Scripting:** Automazione delle logiche di dump e compressione.
*   **Cron:** Schedulazione dei task a livello di sistema operativo.
*   **Linux/LVM:** Partizionamento strategico dello storage e isolamento dei log.

## 🏗️ Architettura
L'infrastruttura prevede l'esecuzione di due container principali interconnessi:
1.  `web_proxy` (Nginx) esposto sulla porta 80.
2.  `staging_db` (PostgreSQL) isolato e con un volume dedicato (`pg_data`) montato sul filesystem dell'host per la persistenza di base.

Per prevenire colli di bottiglia o la saturazione del disco di sistema, è stato ipotizzato un partizionamento LVM strategico separando la root `/`, lo storage Docker `/var/lib/docker` e l'area di salvataggio sicura `/backup`.

## ⚙️ Automazione del Backup
Nonostante l'uso dei volumi Docker, è stato implementato uno script Bash personalizzato (`backup_db.sh`) per garantire backup logici a caldo. Lo script effettua:
1.  Connessione al container DB in esecuzione.
2.  Esecuzione di `pg_dump` con compressione istantanea tramite pipe (`gzip`).
3.  Salvataggio del file `.sql.gz` nella directory dedicata `/backup`.
4.  **Pruning:** Eliminazione automatica dei backup più vecchi di 7 giorni per ottimizzare lo spazio.

Lo script è schedulato tramite **Crontab** per l'esecuzione automatica e silente ogni notte alle 02:00, con reindirizzamento degli output per il monitoraggio:
```bash
0 2 * * * /home/user/scripts/backup_db.sh >> /var/log/docker_backup.log 2>&1
