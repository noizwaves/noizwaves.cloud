# cert-manager

- [Guide](https://levelup.gitconnected.com/easy-steps-to-install-k3s-with-ssl-certificate-by-traefik-cert-manager-and-lets-encrypt-d74947fe7a8)
- [Cloudflare solver config](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/)

## Setup

1. `helm repo add jetstack https://charts.jetstack.io`
1. `helm repo update`
1. Install helm chart:
  ```
  helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    -f values.yaml
  ```
1. Add Cloudflare API token as secret:
  ```
  kubectl --namespace cert-manager create secret generic cloudflare-api-token-secret \
      --from-literal=api-token=<TOKEN>
  ```

## Updating

`helm upgrade --namespace cert-manager cert-manager jetstack/cert-manager -f values.yaml`
