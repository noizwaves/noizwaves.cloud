# nfty

1. `mkdir -p ~/cloud-data/ntfy`
1. `cp server.template.yml server.yml` and edit
1. `docker-compose up -d`
1. `docker exec -it ntfy ntfy user add --role=admin adam`
