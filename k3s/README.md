# k3s

## Setup

1. Set up envrc:
    1. `cp .envrc.template .envrc`
    1. Edit `.envrc` and set the values
    1. `direnv allow`
1. Install k3s: `curl -sfL https://get.k3s.io | sh -s`
1. Configure Traefik
    ```yaml
    # /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
    apiVersion: helm.cattle.io/v1
    kind: HelmChartConfig
    metadata:
    name: traefik
    namespace: kube-system
    spec:
    valuesContent: |-
      #Traefik debugging
      #additionalArguments:
      #  - "--log.level=DEBUG"
      ports:
        web:
          exposedPort: 8080
        websecure:
          exposedPort: 8443
    ```
1. Get Kube config:
    1. `sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/k3s`
    1. `sudo chown cloud:cloud ~/.kube/k3s`
1. `kubectl get nodes`

## Other steps

1. Install a recent version of Helm
1. [Install Tailscale operator](./tailscale/README.md)
1. [Install cert-manager](./cert-manager/README.md)
