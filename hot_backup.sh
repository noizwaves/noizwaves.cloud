#!/usr/bin/env bash

source ~/cloud-config/backup.env
source ~/cloud-config/hot.env

docker stop -t 60 $CONTAINERS

docker run --rm \
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
  --include '/data/' \
  --exclude '**' \
  /data/ "${BACKUP_URL}"

docker start $CONTAINERS

docker run --rm \
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
