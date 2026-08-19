# Minio

1. `$ mkdir -p ~/cloud-data/minio/data`
1. `$ cp .env.tmpl .env`
1. Fill in appropriate values
1. `$ docker-compose up -d`
1. Navigate to [Minio Console](https://minio.dell.noizwaves.cloud)
1. Use S3-compatible API using:
    - Bucket Name: `s3://BUCKET_NAME`
    - Endpoint URL: `https://s3.dell.noizwaves.cloud`
    - Region Name: `dell`
