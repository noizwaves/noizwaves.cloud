#!/usr/bin/env bash

source cold.env

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
