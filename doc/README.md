<span style="color:blue"> Stardog with Azure AD Integration</span>
===================

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

<img src="https://s3.amazonaws.com/stardog-logos.public/stardog-logo.png" alt="drawing" width="70"/> 
<p>&nbsp;</p>

## <span style="color:blue">Stardog Configuration. </span>

### 1. Import stardog-sa Helm chart from repo.


Create license secret
```
$ kubectl -n <your-namespace> create secret generic stardog-license --from-file stardog-license-key.bin=/path/to/stardog-license-key.bin

$ helm repo add stardog-sa https://stardog-union.github.io/helm-chart-sa/
```

### 2. Install stardog using helm chart

cluster_values.yaml

```
replicaCount: 3

cluster:
  enabled: true

waitForStartSeconds: 120
podManagementPolicy: Parallel

image:
  repository: pupsdacr.azurecr.io/stardog/pup-stardog
  tag: '1.0'
  pullPolicy: Always

# The storage class and size to use for Stardog home volumes for the pods
persistence:
  storageClass: default
  size: 20Gi

resources:
 requests:
   cpu: 3400m
   memory: Gi
 limits:
   cpu: 4
   memory: 13Gi

service:
  type: ClusterIP
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-tcp-idle-timeout: "30"

oauth:
  enabled: false
  azure:
    issuer: "https://launchpad.pup.sd-testlab.com" 
    usernameField: username
    audience: "https://sparql.pup.sd-testlab.com"
    keyUrl: "https://launchpad.pup.sd-testlab.com/.well-known/jwks.json"
    autoCreateUsers: true
    allowedGroupIdentifiers:
    - azure.microsoft.com/ff24ca66-bbaa-4def-8acf-43f2635ada42

stardogProperties: |
  security.named.graphs=true
  sql.server.enabled=true
  query.all.graphs=true
  spatial.use.jts=true
  metrics.reporter=jmx
  metrics.jvm.enabled=true
  metrics.jmx.remote.access=true
  query.timeout=1h
  logging.slow_query.enabled=true
  logging.slow_query.time=15m
  logging.slow_query.type=text
  logging.slow_query.rotation.type=time
  logging.slow_query.rotation.interval=7d
  logging.audit.enabled=true
  logging.audit.type=binary
  logging.audit.rotation.type=time
  logging.audit.rotation.interval=7d
  storage.starrocks.enable_snmp=true
  storage.statistics.timing=true
  jwt.sign.with.password=false
  jwt.disable=false

ports:
  server: 5820
  sql: 5806

jvm:
  minHeap: 5g
  maxHeap: 5g
  directMem: 10g
# Java args for Stardog server
javaArgs: "-XX:ActiveProcessorCount=3"

securityContext:
  enabled: true
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000

livenessProbe:
  initialDelaySeconds: 180

readinessProbe:
  initialDelaySeconds: 180

zookeeper:
  enabled: true
  replicaCount: 3
  persistence:
    enabled: true
    storageClass: default
    size: 5Gi
  resources:
    requests:
      memory: 2Gi
      cpu: 1

ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "900"
    nginx.ingress.kubernetes.io/proxy-body-size: "512m"
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: letsencrypt
  className: nginx
  dnsZone: pup.sd-testlab.com
  server:
    url: sparql
    path: /(.*)
    pathtype: Prefix
  sql:
    url: bi
    path: /(.*)
    pathtype: Prefix
  tls:
    enabled: true

```

Create the the namespace.

```
kubectl create ns stardog-ns
```

Create stardog license Secret:

```
kubectl create secret generic stardog-license --from-file stardog-license-key.bin=stardog-license-key.bin
```

Install Stardog helm.

```
helm upgrade -i stardog -n stardog-ns --values cluster_values.yaml stardog-sa/stardog  --debug --timeout 5m
```

> **Note:** Validate that stardog is up and running. 

Configure Azure AD.

Follow the documentation for configure Azuere AD.

[Documentation Stardog-Azure AD](./README-Azure-AD.md)


Create roles on stardog

```
POD_NAME=$(kubectl get pods --namespace sol-ns -l "app.kubernetes.io/name=stardog,app.kubernetes.io/instance=stardog" -o jsonpath="{.items[0].metadata.name}")

kubectl exec -it $POD_NAME sh
```

Execute inside the container.

```
$ stardog-admin role add writer
Successfully added role writer.

$ stardog-admin role grant -a "write" -o "*:*" writer
Successfully granted the permission.
```

 ### 3. Install Launchpad.

 
Create jwt secret for Azure AD.

To Generate New Key Pair
 
``` 
openssl genrsa -out key.pem.key 4096 
openssl rsa -in cert.key -out pubkey-key.pub -outform PEM -pubout
```

Create secret

```
kubectl create secret generic launchpad-jwt-secret -n stardog-ns --from-file=cert-key=cert.key --from-file=public-key=pubkey-key.pub
```

### 2. Install launchpad using helm chart

launchpad_values.yaml
```
replicaCount: 1

image:
  repository: pupsdacr.azurecr.io/stardog/pup-launchpad
  tag: "1.0"
  pullPolicy: Always

imagePullSecrets:
- name: regcred

env:
- name: FRIENDLY_NAME
  value: Stardog Applications (pup)
- name: BASE_URL
  value: https://launchpad.pup.sd-testlab.com
- name: SECURE
  value: "false"
- name: K8S_DEPLOYMENT
  value: "true"
- name: STARDOG_INTERNAL_ENDPOINT
  value: https://sparql.pup.sd-testlab.com
- name: STARDOG_EXTERNAL_ENDPOINT
  value: https://sparql.pup.sd-testlab.com
- name: PASSWORD_AUTH_ENABLED
  value: "true"
- name: AZURE_AUTH_ENABLED
  value: "true"
- name: AZURE_CLIENT_ID
  value: 17476629-0a26-4e0c-8d1d-7b913c9c4831
- name: AZURE_CLIENT_SECRET
  value: prT8Q~hL2npX8YxEw595xDr7QWuUdj_GrjeNYa8U
- name: AZURE_TENANT
  value: ff24ca66-bbaa-4def-8acf-43f2635ada42

service:
  type: ClusterIP
  port: 8080

jwt:
  enabled: true
  secretName: launchpad-jwt-secret

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    meta.helm.sh/release-name: pup-sd
    meta.helm.sh/release-namespace: pup-sd
    nginx.ingress.kubernetes.io/proxy-body-size: 512m
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "900"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
  - host: launchpad.pup.sd-testlab.com
    paths:
    - path: /
      pathType: Prefix
  tls:
  - hosts:
    - launchpad.pup.sd-testlab.com
    secretName: tls-secret-launchpad
   
```

Install Launchpad Helm Chart.
```
helm install launchpad -n stardog-ns -f launchpad_values.yaml stardog-sa/launchpad --debug --timeout 5m
```

