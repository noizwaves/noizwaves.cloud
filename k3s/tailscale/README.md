# tailscale

Follow the [Tailscale docs](https://tailscale.com/kb/1236/kubernetes-operator) to install the operator.

To install the helm chart:
```
helm upgrade \
  --install \
  tailscale-operator \
  tailscale/tailscale-operator \
  --namespace=tailscale \
  --create-namespace \
  --set-string oauth.clientId=<OAauth client ID> \
  --set-string oauth.clientSecret=<OAuth client secret> \
  --wait
```
