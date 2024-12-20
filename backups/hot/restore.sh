#!/usr/bin/env bash

source ~/cloud-config/backups/backup.env
source ~/cloud-config/backups/hot/hot.env

if [ -z "$RESTORE_DIR" ]; then
	echo "RESTORE_DIR is not set; set in hot.env"
	exit 1
fi

if [ -d "$RESTORE_DIR" ]; then
	echo "$RESTORE_DIR already exists; delete it then re-run"
	exit 1
fi

mkdir -p "${RESTORE_DIR}"

# To restore a specific directory, add:
# --file-to-restore cloud-data/resilio-sync/data/zettlekasten-data/Daily \

docker run \
	--name duplicity-hot \
	--hostname duplicity \
	--user 1000:1000 \
	--rm \
	-v /etc/localtime:/etc/localtime:ro \
	-v $(pwd)/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	-v "${RESTORE_DIR}":/restore:rw \
	-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
	-e PASSPHRASE="${PASSPHRASE}" \
	wernight/duplicity:stable \
	duplicity restore \
	--progress \
	s3://${BUCKET_NAME} /restore --s3-endpoint-url=${ENDPOINT_URL} --s3-region-name=${REGION_NAME}
