#!/usr/bin/env bash

source cold.env

if [ -z "$RESTORE_DIR" ]; then
	echo "RESTORE_DIR is not set; set in cold.env"
	exit 1
fi

if [ -d "${RESTORE_DIR}" ]; then
	echo "${RESTORE_DIR} already exists; delete it then re-run"
	exit 1
fi

mkdir -p "${RESTORE_DIR}"

# To restore a specific directory, add:
# --file-to-restore cloud-data/resilio-sync/data/zettlekasten-data/Daily \

docker run \
	--name duplicity-cold \
	--hostname duplicity-cold \
	--user 1000:1000 \
	--rm \
	-v /etc/localtime:/etc/localtime:ro \
	-v $(pwd)/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	-v "${BACKUP_DIR}":/backup:ro \
	-v "${RESTORE_DIR}":/restore:rw \
	wernight/duplicity:stable \
	duplicity restore \
	--progress \
	--no-encryption \
	file:///backup /restore
