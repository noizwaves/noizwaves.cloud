# immich

1. `helm repo add immich https://immich-app.github.io/immich-charts`
1. `helm repo update`
1. `kubectl create namespace immich`
1. `kubectl apply -f pvc.yml`
1. `helm install --namespace immich immich immich/immich -f values.yaml`
