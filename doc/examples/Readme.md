### NGINX Ingress Installation
```
helm upgrade --install  ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx \
 --namespace ingress-nginx --create-namespace \
 --set controller.publishService.enabled=true \
 --set controller.service.annotations."service\.beta.kubernetes\.io/azure-load-balancer-internal"="true" \
 --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz 
 ```

### Install Cert manager

helm upgrade --install --repo https://charts.jetstack.io \
  cert-manager cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version "v1.14.1" \
  --set installCRDs=true

### Create namespace
kubectl create namespace stardog-ns

### create secret of key:
kubectl -n stardog-ns create secret generic stardog-license --from-file stardog-license-key.bin=./doc/private-notes/stardog-license-key.bin

### Stardog Single Node
helm install -n stardog-ns -f ./doc/examples/values-single-stardog.yaml sd-test ./doc/package-test/stardog-3.0.0.tgz 

### Launchpad
helm install -n stardog-ns -f ./doc/examples/values-launchpad.yaml sd-test ./doc/package-test/stardog-3.0.0.tgz --debug  --dry-run

### Stardog Single Node and Launchpad
helm install -n stardog-ns -f ./doc/examples/values-single-stardog-launchpad.yaml sd-test ./doc/package-test/stardog-3.0.0.tgz --debug  --dry-run

### Stardog Cluster and Launchpad Ingress
helm install -n stardog-ns -f ./doc/examples/values-cluster-stardog-launchpad.yaml sd-test ./doc/package-test/stardog-3.0.0.tgz --debug  --dry-run

### Stardog Cluster, Launchpad, Ingress and Azure Entra Id Integration
helm install -n stardog-ns -f ./doc/examples/values-cluster-stardog-launchpad-azure.yaml sd-test ./doc/package-test/stardog-3.0.0.tgz --debug  --dry-run


### Remove helm chart intallation.
helm delete sd-test  --namespace stardog-ns