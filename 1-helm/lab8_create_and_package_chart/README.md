# Create and Package Helm Charts

## 1. Introduction
We will learn the following things
1. `helm create` to create a new Helm Chart
2. Update the Chart with basic information like our Docker Image, appversion, chart version 
3. Update the Chart to support to LoadBalancer Service, helm install and test
4. `helm package `
5. `helm package --app-version --version`
- [Docker Image used](https://github.com/users/hungtran84/packages/container/package/frontend)

## 2. Helm Create Chart
```sh
# Helm Create Chart
helm create myfirstchart

# Observation: 
1. It will create a base Helm Chart template 
2. We can call it as a starter chart. 
```

## 3. Update values.yaml with our Application Docker Image
- [Docker Image used](https://github.com/users/hungtran84/packages/container/package/frontend)

```yaml
# values.yaml
image:
  repository: ghcr.io/hungtran84/frontend
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""
```

## 4. Convert the Kubernetes Service to LoadBalancer type
```yaml
# Update values.yaml
service:
  type: LoadBalancer
  port: 80
  targetPort: 4200


# Remove the default readiness/liveness probe

```

## 5. Update Chart.yaml
```yaml
### Chart Version and Description
# Before
version: 0.1.0
description: A Helm chart for Kubernetes

# After
version: 1.0.0
description: A Helm Chart with LoadBalancer Service

### appVersion
# Before
appVersion: "1.16.0"

# After (update our Docker Image tag version)
appVersion: "1.0"
```

## 6. Helm Install - Chart Version 1.0.0 and Test it
```sh
# Helm Install
helm install myapp1v1 myfirstchart

# List Helm Releases
helm list
helm list --output=yaml

# Helm Status
helm status myapp1v1 --show-resources

# Using kubectl commands
kubectl get pods
kubectl get svc

# Access in Browser
export SERVICE_IP=$(kubectl get svc --namespace default myapp1v1-myfirstchart --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")

open http://$SERVICE_IP:80
```
## 7. Helm Package - v1.0.0
```sh
# Helm Package
helm package myfirstchart/ --destination 1-helm/lab8_create_and_package_chart/packages/

# Review Package file
ls -lrta 1-helm/lab8_create_and_package_chart/packages/
```

## 8. Helm Package - v1.1.0
```sh
### Chart Version and Description
# Before
version: 1.0.0
description: A Helm Chart with LoadBalancer Service

# After
version: 1.1.0
description: A Helm Chart with LoadBalancer Service

### appVersion
# After (update our Docker Image tag version)
appVersion: "1.0"

# After (update our Docker Image tag version)
appVersion: "1.1"

# Helm Package
helm package myfirstchart/ --destination 1-helm/lab8_create_and_package_chart/packages/

```

## 9. Helm Install by path to a packaged chart and Verify
```sh
# Helm Install
helm install myapp1v11 1-helm/lab8_create_and_package_chart/packages/myfirstchart-1.1.0.tgz

# Using kubectl commands
kubectl get pods
kubectl get svc

# List Helm Releases
helm list
helm list --output=yaml

# Helm Status
helm status myapp1v11 --show-resources

# Access in Browser
export SERVICE_IP=$(kubectl get svc --namespace default myapp1v1-myfirstchart --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")

open http://$SERVICE_IP:80
```

## 10. Helm Package with --app-version, --version
- [Docker Image used](https://github.com/users/hungtran84/packages/container/package/frontend)
```t
# Helm Package  --app-version
helm package myfirstchart/ --app-version "2.0" --version "2.0.0" --destination 1-helm/lab8_create_and_package_chart/packages/
```

## 11. Helm Install and Test if --version "2.0.0" worked
```t
# Helm Install from package
helm install myapp1v2 1-helm/lab8_create_and_package_chart/packages/myfirstchart-2.0.0.tgz

# Using kubectl commands
kubectl get pods
kubectl get svc

# List Helm Releases
helm list
helm list --output=yaml

# Helm Status
helm status myapp1v2 --show-resources

# Access in Browser
export SERVICE_IP=$(kubectl get svc --namespace default myapp1v1-myfirstchart --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")

open http://$SERVICE_IP:80
```

## 12. Uninstall Helm Releases
```sh
# List Helm Releases
helm list
helm list --output=yaml

# Uninstall Helm Releases
helm uninstall myapp1v1
helm uninstall myapp1v11
helm uninstall myapp1v2

# Cleanup helm chart
rm -rf myfirstchart
```
## 13. Helm Show Commands
- **helm show:** show information of a chart
```sh
# Helm Show Chart
helm show chart myfirstchart/
helm show chart 1-helm/lab8_create_and_package_chart/packages/myfirstchart-2.0.0.tgz

# Helm Show Values
helm show values myfirstchart/
helm show values 1-helm/lab8_create_and_package_chart/packages/myfirstchart-2.0.0.tgz

# Helm Show readme
helm show readme myfirstchart/
helm show readme 1-helm/lab8_create_and_package_chart/packages/myfirstchart-2.0.0.tgz

# Helm Show All
helm show all myfirstchart/
helm show all 1-helm/lab8_create_and_package_chart/packages/myfirstchart-2.0.0.tgz

# Cleanup helm chart
rm -rf myfirstchart
```


