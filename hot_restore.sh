#!/usr/bin/env bash

source hot.env

mkdir -p "${RESTORE_DIR}"

docker run \
	--hostname duplicity \
	--user 1000:1000 \
	--rm \
	-v /etc/localtime:/etc/localtime:ro \
	-v "${RESTORE_DIR}":/restore:rw \
	-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
	-e PASSPHRASE="${PASSPHRASE}" \
	wernight/duplicity \
	duplicity restore \
	--progress \
	"${BACKUP_URL}" /restore
