#!/usr/bin/env bash

source hot.env

if [ -z "$RESTORE_DIR" ]; then
	echo "RESTORE_DIR is not set; add to hot.env"
	exit 1
fi

mkdir -p "${RESTORE_DIR}"

# To restore a specific directory, add:
# --file-to-restore cloud-data/resilio-sync/data/zettlekasten-data/Daily \

docker run \
	--name duplicity-hot \
	--hostname duplicity-hot \
	--user 1000:1000 \
	--rm \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	-v "${RESTORE_DIR}":/restore:rw \
	-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
	-e PASSPHRASE="${PASSPHRASE}" \
	wernight/duplicity \
	duplicity restore \
	--progress \
	"${BACKUP_URL}" /restore
