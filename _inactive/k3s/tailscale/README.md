# tailscale

## Setup

Follow the [Tailscale docs](https://tailscale.com/kb/1236/kubernetes-operator) to install the operator.

Prepare a secrets file:
```
cp secrets.example.yaml secrets.yaml
```

Install the helm chart:
```
helm upgrade \
  --install \
  tailscale-operator \
  tailscale/tailscale-operator \
  --namespace=tailscale \
  --create-namespace \
  -f secrets.yaml \
  --wait
```

## Updating

1. `helm repo update`
1. `helm upgrade --namespace tailscale tailscale-operator tailscale/tailscale-operator -f secrets.yaml`
