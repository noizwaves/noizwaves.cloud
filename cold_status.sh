#!/usr/bin/env bash

source ~/cloud-config/backup.env
source ~/cloud-config/cold.env

docker run \
	--hostname duplicity-cold \
	--user 1000:1000 \
	--rm \
	-v "${BACKUP_DIR}":/backup:ro \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	wernight/duplicity \
	duplicity collection-status \
	--no-encryption \
	--no-compression \
	file:///backup
