#!/usr/bin/env bash

source ~/cloud-config/backup.env
source ~/cloud-config/cold2.env

mkdir -p "${RESTORE_DIR}"

docker run \
  --hostname duplicity-cold \
  --user 1000:1000 \
  --rm \
  -v /etc/localtime:/etc/localtime:ro \
  -v "${BACKUP_DIR}":/backup:ro \
  -v "${RESTORE_DIR}":/restore:rw \
  wernight/duplicity \
  duplicity restore \
  --progress \
  --no-encryption \
  file:///backup /restore
