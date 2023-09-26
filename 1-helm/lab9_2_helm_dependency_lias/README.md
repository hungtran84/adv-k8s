# Helm Dependency - Alias

## 1. Introduction
- Condition
- Alias
- Override subchart(child chart) values from parent chart

## 2. Update Parentchart to LoadBalancer Service
```yaml
# values.yaml
service:
  type: LoadBalancer
  port: 80
```

## 3. Chart.yaml
- Understand the importance of `alias` when defining dependencies
```yaml
apiVersion: v2
name: parentchart
description: Learn Helm Dependency Concepts
type: application
version: 0.1.0
appVersion: "1.16.0"
dependencies:
- name: mychart4
  version: "0.1.0"
  repository: "oci://ghcr.io/hungtran84/helm"
  alias: childchart4dev
- name: mychart4
  version: "0.1.0"
  repository: "oci://ghcr.io/hungtran84/helm"
  alias: childchart4qa  
- name: mychart2
  version: "0.4.0"
  repository: "oci://ghcr.io/hungtran84/helm"
  alias: childchart2
```

## 4. Deploy and Test
```sh
# Helm Dependency Update
helm dependency update 1-helm/lab9_2_helm_dependency_lias/parentchart

# Helm Install
helm install myapp1 1-helm/lab9_2_helm_dependency_lias/parentchart --atomic

# Helm List
helm list

# Helm Status
helm status myapp1 --show-resources

# List Deployments
kubectl get deploy

# List Pods
kubectl get pods

# List Services
kubectl get svc

# Access Application
export SERVICE_IP=$(kubectl get svc --namespace default myapp1-parentchart --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")

# parentchart
open http://$SERVICE_IP:80
```

## 5. Uninstall Helm Release
```sh
# Helm Uninstall
helm uninstall myapp1
```