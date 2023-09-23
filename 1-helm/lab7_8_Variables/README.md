# Helm Development - Variables

## 1. Introduction
- How to use Variables ?

## 2. Variables in Helm Templates
```yaml
# Change-1: Add Variable at the top of deployment template
{{- $chartname := .Chart.Name -}}

# Change-2: Add appHelmChart annotation with variable in deployment.yaml
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
        appManagedBy: {{ $.Release.Service }}
        appHelmChart: {{ $chartname }}        
      {{- end }}  
```
```sh
# Helm Template
helm template myapp 1-helm/lab7_8_Variables/helmbasics

# Helm Install with dry-run
helm install myapp 1-helm/lab7_8_Variables/helmbasics --dry-run  

# Observation:
We should see variable value substituted successfully
```

## 3. Test Variables in combination with Pipelines
```yaml
# Add Pipeline with quote and upper function
{{- $chartname := .Chart.Name | quote | upper -}}
apiVersion: apps/v1
kind: Deployment
metadata:
```
```sh
# Helm Template
helm template myapp 1-helm/lab7_8_Variables/helmbasics

# Helm Install with dry-run
helm install myapp 1-helm/lab7_8_Variables/helmbasics --dry-run  

# Helm Install with --atomic
helm install myapp 1-helm/lab7_8_Variables/helmbasics --atomic 

# List Helm Releases
helm list

# List Kubernetes Pods
kubectl get pods

# Helm get manifest
helm get manifest myapp101

# Helm Uninstall
helm uninstall myapp101
```
