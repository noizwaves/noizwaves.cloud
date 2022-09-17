#!/usr/bin/env bash
set -e

source ~/cloud-config/backup.env
source ~/cloud-config/hot.env

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

docker run --rm \
	--name duplicity-hot \
	--hostname duplicity \
	--user 1000:1000 \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-data:/data/cloud-data:ro \
	-v ~/cloud-config:/data/cloud-config:ro \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
	-e PASSPHRASE="${PASSPHRASE}" \
	wernight/duplicity \
	duplicity \
	--progress \
	--full-if-older-than 6M \
	--verbosity info \
	--exclude '/data/cloud-data/resilio-sync/data/storage-data/' \
	--exclude '/data/cloud-data/resilio-sync/data/photography-data/' \
	--exclude '/data/cloud-data/photostructure/library/.photostructure/previews/' \
	--exclude '/data/cloud-data/nextcloud/' \
	--exclude '/data/cloud-data/traefik/' \
	--exclude '/data/cloud-data/pihole/' \
	--exclude '/data/cloud-data/fotos/' \
	--exclude '/data/cloud-data/registry/' \
	--exclude '/data/cloud-data/adguard/tailscale/' \
	--exclude '/data/cloud-data/cloudflare/' \
	--exclude '/data/cloud-data/plex/' \
	--exclude '/data/cloud-data/gitea/data/ssh/' \
	--exclude '/data/cloud-data/tig/' \
	--exclude '/data/cloud-data/photoprism/' \
	--exclude '/data/cloud-data/tandoor/staticfiles/' \
	--include '/data/' \
	--exclude '**' \
	/data/ "${BACKUP_URL}"

# Start containers again
start_containers

# Tidy backups
docker run --rm \
	--name duplicity-hot \
	--hostname duplicity \
	--user 1000:1000 \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-data:/data/cloud-data:ro \
	-v ~/cloud-config:/data/cloud-config:ro \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
	-e PASSPHRASE="${PASSPHRASE}" \
	wernight/duplicity \
	duplicity remove-all-but-n-full 1 \
	"${BACKUP_URL}" \
	--force

# Healthy backup achieved
curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/$HC_HOT_BACKUP_UUID

echo "[hot_backup] Completed backup at $(date)"
