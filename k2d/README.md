# k2d

A Kubernetes-API to Docker translator ([website](https://docs.k2d.io/), [docs](https://docs.k2d.io/)):

> k2d is a single container that runs on a Docker (or Podman) Host, which listens on https port 6443 for a limited number of Kubernetes API calls. When the container receives these Kubernetes API calls, k2d parses and translates them into Docker API instructions, which it then executes on the underlying Docker Host.

1. `mkdir -p ~/cloud-data/k2d/data`
1. `cp .env.tmpl .env` and fill in values
1. `docker-compose up -d`
1. `curl -H "Authorization: Bearer $(echo -n '$K2D_SECRET' | base64 --wrap=0)" https://$TAILSCALE_IP:6443/k2d/kubeconfig` to get KUBE_CONFIG
  - replace `TAILSCALE_IP` with `k2d.odroid.noizwaves.cloud`
