#!/usr/bin/env bash

source ~/cloud-config/backup.env
source ~/cloud-config/hot.env

docker run --rm \
	--name duplicity-hot \
	--hostname duplicity \
	--user 1000:1000 \
	-v /etc/localtime:/etc/localtime:ro \
	-v ~/cloud-config/.duplicity-cache:/home/duplicity/.cache/duplicity:rw \
	-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
	-e PASSPHRASE="${PASSPHRASE}" \
	wernight/duplicity \
	duplicity collection-status \
	s3://${BUCKET_NAME} --s3-endpoint-url=${ENDPOINT_URL}
