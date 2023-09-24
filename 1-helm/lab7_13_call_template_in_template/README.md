# Helm Named Templates - Call Template in Template

## 1. Introduction
- We can call one named template in other named template.

## 2. Update _helpers.tpl 
- We will udpate the template `helmbasics.labels` with `template-in-template` as additional label by calling the named template `helmbasics.resourceName`
```go
{{/* Common Labels */}}
{{- define "helmbasics.labels"}}
    app.kubernetes.io/managed-by: helm
    app: nginx
    chartname: {{ .Chart.Name }}
    template-in-template: {{ include "helmbasics.resourceName" . }}
{{- end }}
```

## 3. Test the changes
```sh
# Helm Template Command
helm template myapp1 1-helm/lab7_13_call_template_in_template/helmbasics

# Helm Install with dry-run command
helm install myapp1 1-helm/lab7_13_call_template_in_template/helmbasics --dry-run

# Helm Install with --atomic flag
helm install myapp1 1-helm/lab7_13_call_template_in_template/helmbasics --atomic

# Helm Uninstall
helm uninstall myapp1
```