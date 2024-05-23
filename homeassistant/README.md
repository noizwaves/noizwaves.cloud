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
1. Allow LAN<>hass connectivity: `sudo ufw allow from $LAN_CIDR to any port 8123`

## Homekit pairing

UFW will block incomming connections from iOS when pairing. Temporarily allow connectivity using:
```
$ sudo ufw allow from $IOS_IP_ADDRESS
```

UFW will block incomming connections from the Homekit bridge after pairing. Allow connectivity using:
```
$ sudo ufw allow from $HOMEKIT_BRIDGE_IP_ADDRESS
```
