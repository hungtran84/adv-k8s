# Helm Development - Flow Control Range Action with List

## 1. Introduction
- Implement `Range` with `List of Values` from `values.yaml`
- Implement on how to call `Helm Variable` in Range loop
 
## 2. Implement "Range Action" with "List of Values"
- **Source Location:** backupfiles/namespace.yaml
- **Destination Location:** helmbasics/templates/namespace.yaml
- **File Name:** namespace.yaml
```yaml
# values.yaml
# Flow Control: Range with List
namespaces:
  - name: myapp1
  - name: myapp2
  - name: myapp3

# Range with List
{{- range .Values.namespaces }}
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .name }}
---  
{{- end }}      
```
```sh
# Helm Template
helm template myapp1 1-helm/lab7_9_range_list/helmbasics

# Helm Install with dry-run
helm install myapp1 1-helm/lab7_9_range_list/helmbasics --dry-run 

# Helm Install and Test
helm install myapp1 1-helm/lab7_9_range_list/helmbasics --atomic
helm list

# Helm Status
helm status myapp1 --show-resources

# List k8s namespaces
kubectl get ns

# Observation:
We should see all the namespaces created

# Uninstall Helm Release
helm uninstall myapp1
```


## 3. Implement "Range Action" with "List of Values" with Variables
- **Source Location:** backupfiles/namespace-with-variable.yaml
- **Destination Location:** helmbasics/templates/namespace-with-variable.yaml
- **File Name:** namespace-with-variable.yaml
```yaml
# values.yaml
# Flow Control: Range with List and Helm Variables
environments:
  - name: dev
  - name: qa
  - name: uat  
  - name: prod    

# Range with List
{{- range $environment := .Values.environments }}
apiVersion: v1
kind: Namespace
metadata:
  name: {{ $environment.name }}
---  
{{- end }}           
```
```sh
# Helm Template
helm template myapp1 1-helm/lab7_9_range_list/helmbasics

# Helm Install with dry-run
helm install myapp1 1-helm/lab7_9_range_list/helmbasics --dry-run 

# Helm Install and Test
helm install myapp1 1-helm/lab7_9_range_list/helmbasics --atomic
helm list

# Helm Status
helm status myapp1 --show-resources

# List k8s namespaces
kubectl get ns

# Observation:
We should see all the namespaces created

# Uninstall Helm Release
helm uninstall myapp1
```
