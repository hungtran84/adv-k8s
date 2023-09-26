# Helm Dependency - Override Subchart Values

## 1. Introduction
- Override subchart(child chart) values from parent chart


## 2. Review Chart.yaml
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
  condition: mychart4.enabled
- name: mychart2
  version: "0.4.0"
  repository: "oci://ghcr.io/hungtran84/helm"
  condition: mychart2.enabled
```

## 2. Review mychart4, mychart2 subchart replicaCount value
```t
# Change Directory
cd 1-helm/lab9_6_helm_dependency_override_subchart_values

# Review mychart4 Values from Helm package 
helm show values parentchart/charts/mychart4-0.1.0.tgz

# Review mychart2 Values from Helm package  
helm show values parentchart/charts/mychart2-0.4.0.tgz 
```

## 4. Update values.yaml
- Override `replicaCount` value in subcharts from parent chart `values.yaml`
```yaml
# Values for Child Charts with Chart Name
mychart4:
  enabled: true
  replicaCount: 3
mychart2:
  enabled: true  
  replicaCount: 3
```

## 5. Deploy and Test 
```sh
# Helm Dependency Update
helm dep up parentchart/

# Helm Install
helm install myapp1 parentchart/ --atomic

# Helm List
helm list

# Helm Status
helm status myapp1 --show-resources

# List Deployments
kubectl get deploy

# List Pods
kubectl get pods

#Observation:
#1. We should see 3 pods for each child chart
#2. 1 pod for parentchart
#3. We have successfully overrided the child chart values from parentchart values.yaml

# Access Application
export SERVICE_IP=$(kubectl get svc --namespace default myapp1-parentchart --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
open http://$SERVICE_IP:80
```

## 6. Uninstall Helm Release
```sh
# Helm Uninstall
helm uninstall myapp1
```