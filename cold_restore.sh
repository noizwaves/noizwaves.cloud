#!/usr/bin/env bash

source cold.env

mkdir -p "${RESTORE_DIR}"

# To restore a specific directory, add:
# --file-to-restore cloud-data/resilio-sync/data/zettlekasten-data/Daily \

docker run \
	--name duplicity-cold \
	--hostname duplicity-cold \
	--user 1000:1000 \
	--rm \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	-v "${BACKUP_DIR}":/backup:ro \
	-v "${RESTORE_DIR}":/restore:rw \
	wernight/duplicity \
	duplicity restore \
	--progress \
	--no-encryption \
	file:///backup /restore
