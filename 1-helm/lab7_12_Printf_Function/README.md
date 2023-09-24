# Helm Printf Function

## 1. Introduction
- **[printf](https://helm.sh/docs/chart_template_guide/function_list/#printf):** Returns a string based on a formatting string and the arguments to pass to it in order.


## 2. Create a Named Template with printf function
```go
{{/* Kubernetes Resource Name: String Concat with Hyphen */}}
{{- define "helmbasics.resourceName" }}
{{- printf "%s-%s" .Release.Name .Chart.Name }}
{{- end }}
```

## 3. Call the named template in deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "helmbasics.resourceName" . }}-deployment 
  labels:
```

## 4. Test the changes
```sh
# Helm Template Command
helm template myapp1 1-helm/lab7_12_Printf_Function/helmbasics

# Helm Install with dry-run command
helm install myapp1 1-helm/lab7_12_Printf_Function/helmbasics --dry-run

# Helm Install with --atomic flag
helm install myapp1 1-helm/lab7_12_Printf_Function/helmbasics --atomic

# Helm Uninstall
helm uninstall myapp1
```