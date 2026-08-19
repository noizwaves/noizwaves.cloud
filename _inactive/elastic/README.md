# Elastic Stack

Inspired by https://github.com/elkninja/elastic-stack-docker-part-one

1. `mkdir -p ~/cloud-data/elastic/{certs,es,kibana,metricbeat,filebeat}`
1. `cp .env.tmpl .env` and fill in values
1. `sudo chown root {filebeat,metricbeat}.yml`
1. `docker-compose up -d`
1. Open [Kibana](https://kibana.noizwaves.cloud) and log in with `elastic:$ELASTIC_PASSWORD`
