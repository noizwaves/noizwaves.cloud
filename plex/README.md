# Plex

Set `LAN_IPV6` in the server's `.envrc` to odroid's stable LAN IPv6 address
in `fd70:c25e:6039:4686::/64` before starting Plex. Use its ULA, rather than a
temporary or link-local address. Plex requires this value to keep IPv6 access
bound to the LAN address.

1.  `$ mkdir -p ~/cloud-data/plex/config ~/cloud-data/plex/data ~/cloud-data/plex/transcode`
1.  Generate a [claim](https://www.plex.tv/claim)
1.  `$ docker-compose up -d`
1.  Open [Plex](https://plex.noizwaves.cloud)

## LAN IPv6 access

Plex accepts direct LAN connections on TCP port 32400 over IPv4 and IPv6.
Existing Tailscale IPv4 and HTTPS access remain available.

The Ansible playbook allows the LAN IPv6 subnet through UFW. To apply that
firewall change manually on odroid:

```sh
sudo ufw allow from fd70:c25e:6039:4686::/64 to any port 32400 proto tcp
sudo ufw status verbose
```

Check that `/etc/default/ufw` has `IPV6=yes` and that the IPv6 rule appears in
the status output. Docker must support publishing an IPv6 host port to the
IPv4 container; this requires its userland proxy with the current IPv4 bridge.

After loading the updated `.envrc`, run `docker compose config --quiet` and
`docker compose up -d` from this directory. From another LAN machine, open
`http://[<odroid-LAN-IPv6>]:32400/web` and verify playback. Also verify existing
IPv4, Tailscale, and HTTPS access. Plex app discovery should be checked separately;
an IPv6 port binding alone does not ensure apps select IPv6.

To roll back IPv6 access, remove its port binding and recreate Plex, then run:

```sh
sudo ufw delete allow from fd70:c25e:6039:4686::/64 to any port 32400 proto tcp
```

## AV1 Direct Play to AppleTV
This [moves AV1 transcoding](https://github.com/currifi/plex_av1_tvos) from the server onto the AppleTV.
1.  `$ curl -Ls -o ~/cloud-data/plex/config/Library/Application\ Support/Plex\ Media\ Server/Profiles/tvOS.xml https://raw.githubusercontent.com/currifi/plex_av1_tvos/main/tvOS.xml`
1.  `$ docker-compose restart`

## References

- Inspired by [pierre-emmanuelJ/plex-traefik](https://github.com/pierre-emmanuelJ/plex-traefik)
