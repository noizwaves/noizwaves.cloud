# K3s

A single node Kubernetes cluster based on K3s.

## Setup

### 1. K3s (for Kubernetes)
1.  `$ cd k3s`
1.  `$ mkdir -p ~/cloud-data/k3s/server ~/cloud-data/k3s/kubeconfig ~/cloud-data/k3s/tailscale`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Use Tailscale token in `docker logs k3s_tailscale` to authenticate
1.  Set up DNS record for `k3s.noizwaves.cloud`
1.  Prepare kubeconfig from `~/cloud-data/k3s/kubeconfig/kubeconfig.yaml`

### 2. Cert Manager (for automatic SSL certificate creation)
1.  `$ cd helm/cert-manager`
1.  `$ helm repo add jetstack https://charts.jetstack.io`
1.  `$ helm repo update`
1.  ```
    $ helm install cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --version v1.11.0 \
        --values values.yaml
    ```
1.  Create Cloudflare DNS API Token secret:
    1.  `cp cloudflare-dns-api-token.template.yaml cloudflare-dns-api-token.yaml`
    1.  Replace `TOKEN_VALUE_HERE` with appropriate token
    1.  `kubectl -n cert-manager apply -f cloudflare-dns-api-token.yaml`
1.  Create ClusterIssuer for Let's Encrypt via `kubectl -n cert-manager apply -f letsencrypt-production.yaml`