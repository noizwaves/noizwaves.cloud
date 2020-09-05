#!/usr/bin/env bash

source ~/cloud-config/backup.env
source ~/cloud-config/cold2.env

docker stop $CONTAINERS

docker run \
  --hostname duplicity-cold \
  --user 1000:1000 \
  --rm \
  -v /etc/localtime:/etc/localtime:ro \
  -v ~/cloud-data:/data/cloud-data:ro \
  -v ~/cloud-config:/data/cloud-config:ro \
  -v "${BACKUP_DIR}":/backup:rw \
  wernight/duplicity \
  duplicity \
  --progress \
  --no-encryption \
  --no-compression \
  --exclude '/data/cloud-data/resilio-sync/data/storage-data/' \
  --exclude '/data/cloud-data/nextcloud/' \
  --exclude '/data/cloud-data/traefik/' \
  --exclude '/data/cloud-data/pihole/' \
  --exclude '/data/cloud-data/fotos/' \
  --include '/data/' \
  --exclude '**' \
  /data file:///backup

docker start $CONTAINERS
