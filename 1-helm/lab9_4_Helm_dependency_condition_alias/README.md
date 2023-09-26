# Helm Dependency - Condition with Alias

## 1. Introduction
- Implement `Condition` for enabling or disabling Sub Charts or Child Charts
- Override subchart(child chart) values from parent chart


## 2. Chart.yaml
- If we have multiple dependencies with same chart name `mychart4` with different alias names like `childchart4dev` and `childchart4qa` in this case we need to define values.yaml with `alias names` for enabling or disabling those sub charts
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
  condition: childchart4dev.enabled
- name: mychart4
  version: "0.1.0"
  repository: "oci://ghcr.io/hungtran84/helm"
  alias: childchart4qa
  condition: childchart4qa.enabled  
- name: mychart2
  version: "0.4.0"
  repository: "oci://ghcr.io/hungtran84/helm"
  alias: childchart2
  condition: childchart2.enabled
```

## 3. Update values.yaml
- Here only `childchart4qa` so only k8s resources for that chart should created in addition to parent chart resources
```yaml
# Values for Child Charts with Alias Name of Chart
childchart4dev:
  enabled: false 
childchart4qa:
  enabled: true   
childchart2:
  enabled: false 
```


## 4 Deploy and Test 
```sh
# Helm Dependency Update
helm dependency update parentchart/

# Helm Install
helm install myapp1 parentchart/ --atomic

# Helm List
helm list

# Helm Status
helm status myapp1 --show-resources

# List Deployments
kubectl get deploy

#Observation:
#1. Resources for childchart4qa should be created in addition to parent chart

# List Pods
kubectl get pods

# List Services
kubectl get svc

# Access Application
export SERVICE_IP=$(kubectl get svc --namespace default myapp1-parentchart --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
open http://$SERVICE_IP:80
```

## 5. Uninstall Helm Release
```sh
# Helm Uninstall
helm uninstall myapp1
```