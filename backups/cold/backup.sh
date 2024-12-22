#!/usr/bin/env bash
set -e

source ~/cloud-config/backups/backup.env
source ~/cloud-config/backups/cold/cold.env

if [ ! -d "$BACKUP_DIR" ]; then
	echo "Directory ${BACKUP_DIR} missing. Is bigbackup mounted?"
	exit 1
fi

if [ ! -d /media/backup/restic ]; then
  echo "backup drive is not mounted!"
  exit 1
fi

if [ ! -d /media/bigbackup/restic ]; then
  echo "bigbackup drive is not mounted!"
  exit 1
fi

DEST="file:///backup"

stop_containers() {
	docker stop -t 60 $CONTAINERS
}

start_containers() {
	docker start $CONTAINERS
}

# Error handling, ensure containers are started again
handle_error() {
	echo "!!! Error taking backup"
	start_containers
	echo "!!! Error taking backup"
}
trap handle_error ERR

# Stop containers in preparation for backup
stop_containers

# restic to backup
restic --repo /media/backup/restic/odroid --insecure-no-password \
  backup \
	--files-from ~/cloud-config/backups/restic_backup.txt \
  --exclude-file ~/cloud-config/backups/restic_exclude.txt

# restic to bigbackup
restic --repo /media/bigbackup/restic/odroid --password-file /media/bigbackup/restic/odroid.password \
  backup \
  --files-from ~/cloud-config/backups/restic_backup.txt \
  --exclude-file ~/cloud-config/backups/restic_exclude.txt

# rsync to bigbackup
rsync --archive --open-noatime --progress --itemize-changes --stats --delete --delete-excluded  \
  --exclude-from ~/cloud-config/backups/rsync_exclude.txt \
  /mnt/media2/ \
  /media/bigbackup/rsync/media2

# Start containers again
start_containers

restic cache --cleanup

# Healthy backup achieved
curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/$HC_COLD_BACKUP_UUID

curl \
	--silent \
	-H "Authorization: Bearer ${NTFY_TOKEN}" \
	-H "Tags: white_check_mark" \
	-d "Backup complete" \
	https://ntfy.noizwaves.cloud/odroid_cold_backups > /dev/null
