# Helm Dependency - Condition

## 1. Introduction
- Implement `Condition` for enabling or disabling Sub Charts or Child Charts
- Override subchart(child chart) values from parent chart


## 2. Chart.yaml
- Understand the importance of `condition` when defining dependencies
- By default, if we the condition is defined or not `condition: mychart4.enabled`, chart is enabled when defined
- To disable it we need to explicitly make it `false` in `values.yaml`
```yaml
dependencies:
- name: mychart4
  version: "0.1.0"
  repository: "oci://ghcr.io/hungtran84/helm"
  alias: childchart4
  condition: mychart4.enabled
- name: mychart2
  version: "0.4.0"
  repository: "oci://ghcr.io/hungtran84/helm"
  alias: childchart2
  condition: mychart2.enabled
```

## 3. Deploy and Test - By Default enabled is true
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

# List Services
kubectl get svc

# Access Application
export SERVICE_IP=$(kubectl get svc --namespace default myapp1-parentchart --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
open http://$SERVICE_IP:80

# Helm Uninstall
helm uninstall myapp1
```

## 4. Update values.yaml
```yaml
# Values for Child Charts with Chart Name
mychart4:
  enabled: false
mychart2:
  enabled: false  
```


## 5. Deploy and Test - when childcharts are disabled
```t
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

#Observation:
#1. Child Charts will not be deployed.
#2. No k8s resources for child charts will be created

# List Pods
kubectl get pods

# List Services
kubectl get svc

# Access Application
export SERVICE_IP=$(kubectl get svc --namespace default myapp1-parentchart --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
open http://$SERVICE_IP:80
```

## 6. Uninstall Helm Release
```sh
# Helm Uninstall
helm uninstall myapp1
```