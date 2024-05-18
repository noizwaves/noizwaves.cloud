# plex

## Setup

Intel Device Driver (for hardware transcoding):
1. `kubectl apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/nfd?ref=v0.30.0'`
1. `kubectl apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/nfd/overlays/node-feature-rules?ref=v0.30.0'`
1. `kubectl apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/gpu_plugin/overlays/nfd_labeled_nodes?ref=v0.30.0'`

Plex:
1. `helm repo add plex https://raw.githubusercontent.com/plexinc/pms-docker/gh-pages`
1. `kubectl create namespace plex`
1. `helm install --namespace plex plex plex/plex-media-server -f values.yaml`

## Updating

1. `helm repo update`
1. `helm upgrade --namespace plex plex plex/plex-media-server -f values.yaml`

## Resources

- [Plex Helm chart](https://github.com/plexinc/pms-docker/blob/master/charts/plex-media-server/README.md)
- [Plex on Kubernetes with Hardware Encoding](https://shadetree.dev/2024/02/03/plex-media-server-on-kubernetes-with-hardware-encoding/)
