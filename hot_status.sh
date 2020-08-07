#!/usr/bin/env bash

source hot.env

DEST="s3://us-east-1.linodeobjects.com/$BUCKET_NAME/"

docker run --rm \
  --hostname duplicity \
  --user 1000:1000 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e PASSPHRASE="${PASSPHRASE}" \
  -e TZ=America/Denver \
  wernight/duplicity \
  duplicity collection-status \
  ${DEST}
