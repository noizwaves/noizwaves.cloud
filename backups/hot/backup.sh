#!/usr/bin/env bash
set -e

source ~/cloud-config/backups/backup.env
source ~/cloud-config/backups/hot/hot.env

stop_containers() {
	echo "[hot_backup] Begin stopping containers"
	docker stop -t 60 $CONTAINERS
	echo "[hot_backup] Completed stopping containers"
}

start_containers() {
	echo "[hot_backup] Begin starting containers"
	docker start $CONTAINERS
	echo "[hot_backup] Completed starting containers"
}

# Error handling, ensure containers are started again
handle_error() {
	echo "[hot_backup] !!! Error taking backup"
	start_containers
	echo "[hot_backup] !!! Error taking backup"
}
trap handle_error ERR

# Stop containers in preparation for backup
echo "[hot_backup] Starting backup at $(date)"

stop_containers

# restic to backblaze
restic backup \
  --files-from ~/cloud-config/backups/restic_backup.txt \
  --exclude-file ~/cloud-config/backups/restic_exclude.txt

# Start containers again
start_containers

# rclone of media to backblaze
for MEDIA_DIR in ${MEDIA_DIRS[@]}; do
  echo "Backing up $MEDIA_DIR"
  rclone sync "$MEDIA_DIR" "crypto:${MEDIA_DIR}" --transfers 8 --progress
done

# Healthy backup achieved
curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/$HC_HOT_BACKUP_UUID

echo "[hot_backup] Completed backup at $(date)"
