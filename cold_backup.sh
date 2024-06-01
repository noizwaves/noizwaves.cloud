#!/usr/bin/env bash
set -e

source ~/cloud-config/backup.env
source ~/cloud-config/cold.env

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

# --verbosity info \
# Perform backup
docker run \
	--name duplicity-cold \
	--hostname duplicity-cold \
	--user 1000:1000 \
	--rm \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-data:/data/cloud-data:ro \
	-v /mnt/media2/Photography:/data/mnt/media/Photography:ro \
	-v ~/cloud-config:/data/cloud-config:ro \
	-v "${BACKUP_DIR}":/backup:rw \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	wernight/duplicity \
	duplicity \
	--progress \
	--full-if-older-than 12M \
	--no-encryption \
	--no-compression \
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
	/data "${DEST}"

# Start containers again
start_containers

# Tidy backups
docker run \
	--name duplicity-cold \
	--hostname duplicity-cold \
	--user 1000:1000 \
	--rm \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-data:/data/cloud-data:ro \
	-v ~/cloud-config:/data/cloud-config:ro \
	-v "${BACKUP_DIR}":/backup:rw \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	wernight/duplicity \
	duplicity cleanup \
	--force \
	--no-encryption \
	${DEST}

docker run \
	--name duplicity-cold \
	--hostname duplicity-cold \
	--user 1000:1000 \
	--rm \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-data:/data/cloud-data:ro \
	-v ~/cloud-config:/data/cloud-config:ro \
	-v "${BACKUP_DIR}":/backup:rw \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	wernight/duplicity \
	duplicity remove-all-but-n-full 2 \
	${DEST} \
	--force

# Healthy backup achieved
curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/$HC_COLD_BACKUP_UUID

curl \
	--silent \
	-H "Authorization: Bearer ${NTFY_TOKEN}" \
	-H "Tags: white_check_mark" \
	-d "Backup complete" \
	https://ntfy.noizwaves.cloud/odroid_cold_backups > /dev/null
