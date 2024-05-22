# homeassistant

1. `mkdir -p ~/cloud-data/homeassistant/config`
1. `docker-compose up -d`
1. Allow HA to accept Traefik forwarded requests:
    ```
    # ~/cloud-data/homeassistant/config/configuration.yaml
    http:
      use_x_forwarded_for: true
      trusted_proxies:
        - 172.18.0.0/16
    ```
1. Allow web network<>Docker host connectivity: `sudo ufw allow proto tcp from $WEB_CIDR to 172.17.0.1 port 8123`
1. Allow LAN<>hass connectivity: `sudo ufw allow from $LAN_CIDR to any port 8123`
