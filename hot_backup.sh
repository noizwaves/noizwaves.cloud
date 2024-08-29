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

# --verbosity info \
# Perform backup
docker run --rm \
	--name duplicity-hot \
	--hostname duplicity \
	--user 1000:1000 \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-data:/data/cloud-data:ro \
	-v /mnt/media2/Photography:/data/mnt/media/Photography:ro \
	-v ~/cloud-config:/data/cloud-config:ro \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
	-e PASSPHRASE="${PASSPHRASE}" \
	wernight/duplicity:stable \
	duplicity \
	--progress \
	--full-if-older-than 6M \
	--exclude '/data/cloud-config/.duplicity-cache/' \
	--exclude '/data/cloud-config/hot_backup.log' \
	--exclude '/data/cloud-config/elastic/filebeat.yml' \
	--exclude '/data/cloud-config/elastic/metricbeat.yml' \
	--exclude '/data/cloud-data/adguard/tailscale/' \
	--exclude '/data/cloud-data/backblaze/' \
	--exclude '/data/cloud-data/bitwarden/data/icon_cache/' \
	--exclude '/data/cloud-data/cloudflare/' \
	--exclude '/data/cloud-data/elastic/' \
	--exclude '/data/cloud-data/fotos-lauren/normals/' \
	--exclude '/data/cloud-data/fotos-lauren/thumbnails/' \
	--exclude '/data/cloud-data/fotos/normals/' \
	--exclude '/data/cloud-data/fotos/thumbnails/' \
	--exclude '/data/cloud-data/gitea/data/ssh/' \
	--exclude '/data/cloud-data/immich/model-cache' \
	--exclude '/data/cloud-data/immich/redis' \
	--exclude '/data/cloud-data/immich/tailscale' \
	--exclude '/data/cloud-data/influxdb/' \
	--exclude '/data/cloud-data/k2d/' \
	--exclude '/data/cloud-data/k3s/' \
	--exclude '/data/cloud-data/nextcloud/' \
	--exclude '/data/cloud-data/photoprism/' \
	--exclude '/data/cloud-data/photostructure/library/.photostructure/previews/' \
	--exclude '/data/cloud-data/pihole-lan/' \
	--exclude '/data/cloud-data/pihole/' \
	--exclude '/data/cloud-data/plex/' \
	--exclude '/data/cloud-data/registry/' \
	--exclude '/data/cloud-data/resilio-sync/data/storage-data/' \
	--exclude '/data/cloud-data/scrutiny/' \
	--exclude '/data/cloud-data/tandoor/staticfiles/' \
	--exclude '/data/cloud-data/tig/' \
	--exclude '/data/cloud-data/traefik/' \
	--exclude '/data/cloud-data/upsnap/' \
	--include '/data/' \
	--exclude '**' \
	/data/ s3://${BUCKET_NAME} --s3-endpoint-url=${ENDPOINT_URL}

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
	wernight/duplicity:stable \
	duplicity remove-all-but-n-full 2 \
	s3://${BUCKET_NAME} --s3-endpoint-url=${ENDPOINT_URL} \
	--force

# Healthy backup achieved
curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/$HC_HOT_BACKUP_UUID

echo "[hot_backup] Completed backup at $(date)"
