#!/usr/bin/env bash

source ~/cloud-config/backups/backup.env
source ~/cloud-config/backups/cold/cold.env

docker run \
	--name duplicity-cold \
	--hostname duplicity-cold \
	--user 1000:1000 \
	--rm \
	-v "${BACKUP_DIR}":/backup:rw \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	wernight/duplicity:stable \
	duplicity cleanup \
	--force \
	--no-encryption \
	--no-compression \
	file:///backup
