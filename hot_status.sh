#!/usr/bin/env bash

source ~/cloud-config/backup.env
source ~/cloud-config/hot.env

DEST="s3://us-east-1.linodeobjects.com/$BUCKET_NAME/"

docker run --rm \
	--name duplicity-hot \
	--hostname duplicity-hot \
	--user 1000:1000 \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
	-e PASSPHRASE="${PASSPHRASE}" \
	wernight/duplicity \
	duplicity collection-status \
	${DEST}
