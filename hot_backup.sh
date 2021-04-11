#!/usr/bin/env bash

source ~/cloud-config/backup.env
source ~/cloud-config/hot.env

DEST="s3://us-east-1.linodeobjects.com/$BUCKET_NAME/"

docker stop -t 60 $CONTAINERS

docker run --rm \
  --hostname duplicity \
  --user 1000:1000 \
  -v /etc/localtime:/etc/localtime:ro \
  -v ~/cloud-data:/data/cloud-data:ro \
  -v ~/cloud-config:/data/cloud-config:ro \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e PASSPHRASE="${PASSPHRASE}" \
  wernight/duplicity \
  duplicity \
  --progress \
  --full-if-older-than 1M \
  --exclude '/data/cloud-data/resilio-sync/data/storage-data/' \
  --exclude '/data/cloud-data/resilio-sync/data/photography-data/' \
  --exclude '/data/cloud-data/photostructure/library/.photostructure/previews/' \
  --exclude '/data/cloud-data/nextcloud/' \
  --exclude '/data/cloud-data/traefik/' \
  --exclude '/data/cloud-data/pihole/' \
  --exclude '/data/cloud-data/fotos/' \
  --exclude '/data/cloud-data/registry/' \
  --include '/data/' \
  --exclude '**' \
  /data/ ${DEST}

docker start $CONTAINERS

docker run --rm \
  --hostname duplicity \
  --user 1000:1000 \
  -v /etc/localtime:/etc/localtime:ro \
  -v ~/cloud-data:/data/cloud-data:ro \
  -v ~/cloud-config:/data/cloud-config:ro \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e PASSPHRASE="${PASSPHRASE}" \
  wernight/duplicity \
  duplicity remove-all-but-n-full 3 \
  ${DEST} \
  --force
