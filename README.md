Stardog Helm Chart
===================

These charts install the Stardog Knowledge Graph platform on Kubernetes. 

Stardog documentation: https://www.stardog.com/docs

Highlights
----------

As of version 3.0.0 of the Stardog Helm charts, ZooKeeper 3.5.7 is now deployed
with the [Bitnami](https://github.com/bitnami/charts/tree/master/bitnami/zookeeper)
ZooKeeper chart. Stardog 7.4.2 includes preview support for ZooKeeper 3.5.x so you
must be running that version of Stardog or later. Please see the Stardog chart
[README](https://github.com/stardog-union/helm-charts/blob/master/charts/stardog/README.md)
for instructions on how to upgrade from version 1.x of the charts to version 2.

We strongly recommend that the charts request at least 2 CPUs or more for Stardog.
By default the Stardog chart requests 2 CPUs. This value can be configured in the
`values.yaml` file.

Prerequisites
-------------

- Stardog Cluster license file
- Helm v3
- Persistent volume support
- Load balancer service
- Familiarity with Stardog Cluster
- Familiarity with Apache ZooKeeper

Installing
----------

To inatall Stardog using helm chart

1. Import the helm repository
```
$ helm repo add stardog https://stardog-union.github.io/helm-charts-sa/
```
2. Create namespace for stardog.
```
$ kubectl create namespace <your-namespace>
```

3. Create secret for stardog-license.
```
$ kubectl -n <your-namespace> create secret generic stardog-license --from-file stardog-license-key.bin=/path/to/stardog-license-key.bin
```

3. 

```
$ kubectl -n <your-namespace> create secret generic stardog-license --from-file stardog-license-key.bin=/path/to/stardog-license-key.bin
$ helm repo add stardog https://stardog-union.github.io/helm-charts-sa/
$ helm install <helm-release-name> --namespace <your-namespace> stardog/stardog
```

See the Stardog chart's [README](https://github.com/stardog-union/helm-charts/blob/master/charts/stardog/README.md)
for a list of configuration parameters.

See [Enable Ingress controller Configuration](README-ingress.md) for enable Ingress controller

Deleting
--------

```
$ helm delete <helm-release-name> --namespace <your-namespace>
```

Values Properties
-----------------

| Value Property                 | Default Value  | Is Required | Description                 |
|-------------------------------|-------------|-------------|-----------------------|
| `stardog.enabled`                             | `true`                                                | No          | Enable or disable the Stardog component in the chart.                                                    |
| `stardog.licenseServer.enabled`               | `false`                                               | No          | Enable or disable the license server for Stardog.                                                        |
| `stardog.licenseServer.licenseType`           | `unlimited`                                           | No          | Type of license for Stardog (e.g., `unlimited`).                                                         |
| `stardog.licenseServer.url`                   | `""`                                                  | No          | URL of the Stardog license server.                                                                       |
| `stardog.stardogCloudType`                    | `""`                                                  | No          | Specifies the type of Stardog cloud deployment.                                                          |
| `stardog.cluster.enabled`                     | `false`                                               | No          | Enable or disable clustering for Stardog.                                                                |
| `stardog.cluster.replicaCount`                | `1`                                                   | No          | Number of replicas in the Stardog cluster.                                                               |
| `stardog.podManagementPolicy`                 | `OrderedReady`                                        | No          | Pod startup policy, either `OrderedReady` for sequential starts or `Parallel` for all at once.           |
| `stardog.terminationGracePeriodSeconds`       | `300`                                                 | No          | Time in seconds before forcefully killing pods on shutdown.                                              |
| `stardog.jvm.minHeap`                         | `1g`                                                  | No          | Minimum heap size for the JVM running Stardog.                                                           |
| `stardog.jvm.maxHeap`                         | `1g`                                                  | No          | Maximum heap size for the JVM running Stardog.                                                           |
| `stardog.jvm.directMem`                       | `2g`                                                  | No          | Size of the direct memory allocation pool for the JVM.                                                   |
| `stardog.javaArgs`                            | `""`                                                  | No          | Additional JVM arguments to pass to Stardog.                                                             |
| `stardog.service.type`                        | `ClusterIP`                                           | No          | Kubernetes Service type for Stardog.                                                                     |
| `stardog.ports.server`                        | `5820`                                                | No          | Port to expose the Stardog server.                                                                       |
| `stardog.ports.sql`                           | `5806`                                                | No          | Port to expose Stardog's SQL server.                                                                     |
| `stardog.ssl.enabled`                         | `false`                                               | No          | Enable or disable SSL for Stardog.                                                                       |
| `stardog.tmpDir`                              | `/tmp`                                                | No          | Temporary directory path inside Stardog pods.                                                            |
| `stardog.admin.password`                      | `admin`                                               | No          | Initial password for the Stardog admin user.                                                             |
| `stardog.image.registry`                      | `https://registry.hub.docker.com/v2/repositories`    | No          | Docker registry for the Stardog image.                                                                   |
| `stardog.image.repository`                    | `stardog/stardog`                                     | No          | Docker repository for the Stardog image.                                                                 |
| `stardog.image.tag`                           | `latest`                                              | No          | Docker image tag for the Stardog image.                                                                  |
| `stardog.image.pullPolicy`                    | `IfNotPresent`                                        | No          | Image pull policy for the Stardog Docker image.                                                          |
| `stardog.image.username`                      | `""`                                                  | No          | Username for Docker registry authentication.                                                             |
| `stardog.image.password`                      | `""`                                                  | No          | Password for Docker registry authentication.                                                             |
| `stardog.persistence.storageClass`            | `""`                                                  | No          | Storage class for Stardog volumes.                                                                       |
| `stardog.persistence.size`                    | `5Gi`                                                 | No          | Size of the persistent volume for Stardog.                                                               |
| `stardog.antiAffinity`                        | `requiredDuringSchedulingIgnoredDuringExecution`     | No          | Pod anti-affinity settings.                                                                              |
| `stardog.resources.requests.cpu`              | `1`                                                   | No          | Requested CPU resources for Stardog pods.                                                                |
| `stardog.resources.requests.memory`           | `1Gi`                                                 | No          | Requested memory resources for Stardog pods.                                                             |
| `stardog.resources.limits.cpu`                | `2`                                                   | No          | CPU resource limits for Stardog pods.                                                                    |
| `stardog.resources.limits.memory`             | `2Gi`                                                 | No          | Memory resource limits for Stardog pods.                                                                 |
| `stardog.enableAuditSidecar`                  | `false`                                               | No          | Enable or disable the audit log sidecar container.                                                       |
| `stardog.securityContext.runAsNonRoot`        | `true`                                                | No          | Enforce running containers as non-root user.                                                             |
| `stardog.securityContext.runAsUser`           | `1000`                                                | No          | UID to run the container as.                                                                             |
| `stardog.securityContext.runAsGroup`          | `1000`                                                | No          | GID to run the container as.                                                                             |
| `stardog.securityContext.fsGroup`             | `1000`                                                | No          | GID for volume mounts within the container.                                                              |
| `stardog.livenessProbe.initialDelaySeconds`   | `30`                                                  | No          | Initial delay before starting the liveness probe.                                                        |
| `stardog.readinessProbe.initialDelaySeconds`  | `90`                                                  | No          | Initial delay before starting the readiness probe.                                                       |
| `launchpad.enabled`                           | `false`                                               | No          | Enable or disable the Launchpad component in the chart.                                                  |
| `launchpad.replicaCount`                      | `1`                                                   | No          | Number of replicas for the Launchpad component.                                                          |
| `launchpad.service.type`                      | `ClusterIP`                                           | No          | Kubernetes Service type for Launchpad.                                                                   |
| `launchpad.service.port`                      | `8080`                                                | No          | Port for the Launchpad service.                                                                          |
| `launchpad.tls.enabled`                       | `false`                                               | No          | Enable or disable TLS for Launchpad.                                                                     |
| `launchpad.ingress.enabled`                   | `false`                                               | No          | Enable or disable ingress for Launchpad.                                                                 |
| `launchpad.ingress.className`                 | `nginx`                                               | No          | Ingress class name for Launchpad.                                                                        |
| `launchpad.ingress.url`                       | `launchnpad.stardogcloud.com`                         | No          | URL for Launchpad ingress.                                                                               |
| `launchpad.resources.requests.cpu`            | `1`                                                   | No          | Requested CPU resources for Launchpad pods.                                                              |
| `launchpad.resources.requests.memory`         | `1Gi`                                                 | No          | Requested memory resources for Launchpad pods.                                                           |
| `launchpad.resources.limits.cpu`              | `2`                                                   | No          | CPU resource limits for Launchpad pods.                                                                  |
| `launchpad.resources.limits.memory`           | `2Gi`                                                 | No          | Memory resource limits for Launchpad pods.                                                               |
| `launchpad.serviceAccount.create`             | `true`                                                | No          | Specifies whether a service account for Launchpad should be created.                                     |
| `launchpad.securityContext.runAsNonRoot`      | `true`                                                | No          | Enforce running Launchpad containers as non-root user.                                                   |
| `launchpad.securityContext.runAsUser`         | `1000`                                                | No          | UID to run the Launchpad container as.                                                                   |
| `launchpad.securityContext.runAsGroup`        | `1000`                                                | No          | GID to run the Launchpad container as.                                                                   |
| `launchpad.image.registry`                    | `https://registry.hub.docker.com/v2/repositories`    | No          | Docker registry for the Launchpad image.                                                                 |
| `launchpad.image.repository`                  | `stardog/launchpad`                                   | No          | Docker repository for the Launchpad image.                                                               |
| `launchpad.image.tag`                         | `latest`                                              | No          | Docker image tag for the Launchpad image.                                                                |
| `launchpad.image.pullPolicy`                  | `IfNotPresent`                                        | No          | Image pull policy for the Launchpad Docker image.                                                        |
| `zookeeper.enabled`                           | `false`                                               | No          | Enable or disable Zookeeper component in the chart.                                                      |



Running the tests locally
-------------------------

This assume you have Docker installed and running this on MacOs. For other systems, install their corresponding binaries.

## Install minikube
```
# Get the one from here https://github.com/kubernetes/minikube/releases For macos, this is the latest version
curl -Lo minikube https://github.com/kubernetes/minikube/releases/download/<minikube-version>/minikube-darwin-arm64
chmod +x minikube
sudo mv minikube /usr/local/bin/
```

## Start minikube
Your k8s version should be the same as your kubectl version. This will update you ~/.kube/config file and set minikube to the current context.
```
minikube start --driver=docker --kubernetes-version=v.1.29.0
```

## Set up the Stardog license
Make sure you have a proper stardog license called `stardog-license-key.bin` located in the root directory of this project.
```
kubectl create secret generic stardog-license --from-file stardog-license-key.bin=stardog-license-key.bin
```

## Install Stardog as a helm release
```
helm install stardog charts/stardog/ --wait --timeout 15m -f tests/minikube.yaml \
--set "cluster.enabled=false" \
--set "replicaCount=1" \
--set "zookeeper.enabled=false"
```

## Run the tests
 ./tests/smoke.sh