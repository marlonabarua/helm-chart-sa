Stardog Helm Chart
===================

These charts install the Stardog Knowledge Graph platform on Kubernetes. 

Stardog documentation: https://www.stardog.com/docs

To install Stardog on kubernetes environment depends of your setup you may need install Cert-manager and/or NGINX Ingress helm charts.

1. Cert-manager installation steps.

```helm upgrade --install --repo https://charts.jetstack.io \
  cert-manager cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version "v1.14.1" \
  --set installCRDs=true
```
For more configuration info please [click here](https://cert-manager.io/docs/installation/helm/)

2. NGINX Ingress installation steps. 

helm upgrade --install --repo https://charts.jetstack.io \
  
  ```
helm upgrade --install  ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx \
 --namespace ingress-nginx --create-namespace \
 --set controller.publishService.enabled=true \
 --set controller.replicaCount=2
 ```

For azure AKS
```
helm upgrade --install  ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx \
 --namespace ingress-nginx --create-namespace \
 --set controller.publishService.enabled=true \
 --set controller.replicaCount=2 \
 --set controller.service.annotations."service\.beta.kubernetes\.io/azure-load-balancer-internal"="true" \
 --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz 
 ```

For more configuration info please [click here](https://kubernetes.github.io/ingress-nginx/deploy/)
 