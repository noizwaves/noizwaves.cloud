#!/usr/bin/env bash

source ~/cloud-config/backup.env
source ~/cloud-config/cold.env

DEST="file:///backup"

docker stop -t 60 $CONTAINERS

docker run \
  --hostname duplicity-cold \
  --user 1000:1000 \
  --rm \
  -v /etc/localtime:/etc/localtime:ro \
  -v ~/cloud-data:/data/cloud-data:ro \
  -v ~/cloud-config:/data/cloud-config:ro \
  -v "${BACKUP_DIR}":/backup:rw \
  -v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
  wernight/duplicity \
  duplicity \
  --progress \
  --full-if-older-than 12M \
  --no-encryption \
  --no-compression \
  --exclude '/data/cloud-data/resilio-sync/data/storage-data/' \
  --exclude '/data/cloud-data/photostructure/library/.photostructure/previews/' \
  --exclude '/data/cloud-data/nextcloud/' \
  --exclude '/data/cloud-data/traefik/' \
  --exclude '/data/cloud-data/pihole/' \
  --exclude '/data/cloud-data/fotos/' \
  --exclude '/data/cloud-data/registry/' \
  --exclude '/data/cloud-data/adguard/tailscale/' \
  --exclude '/data/cloud-data/cloudflare/' \
  --exclude '/data/cloud-data/plex/' \
  --include '/data/' \
  --exclude '**' \
  /data "${DEST}"

docker start $CONTAINERS

docker run \
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
