# immich

1. `helm repo add immich https://immich-app.github.io/immich-charts`
1. `helm repo update`
1. `kubectl create namespace immich`
1. `kubectl apply -f pvc-library.yml`
1. `kubectl apply -f pvc-cache.yml`
1. `helm install --namespace immich immich immich/immich -f values.yaml`

To upgrade:
1. Change version in `values.yaml`
1. `helm repo update`
1. `helm upgrade --namespace immich immich immich/immich -f values.yaml`
