# Helm Development - Named Templates

## 1. Introduction
- Create Named Template
- Call the named template using template action
- Pass Root Object dot (.) to template action provided if we are using Helm builtin objects in our named template
- For `template call` use `pipelines` and see if it works
- Replace `template call` with special purpose function `include` in combination with `pipelines` and test it


## 2. Create a Named Template
- **File Location:** deployment.yaml
- Define the below named template in `_helpers.tpl`
```yaml
# _helpers.tpl
{{/* Common Labels */}}
{{- define "helmbasics.labels"}}
    app: nginx
{{- end }}
```

## 3. Call the named template using template action
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}-deployment 
  labels:
  {{- template "helmbasics.labels" }}
```

## 4. Test the output with template action
```sh
# Helm Template Command
helm template myapp101 1-helm/lab7_11_named_templates/helmbasics

# Helm Install with dry-run command
helm install myapp101 1-helm/lab7_11_named_templates/helmbasics --dry-run

# Helm Release
helm install myapp101 1-helm/lab7_11_named_templates/helmbasics --atomic
kubectl get deploy
kubectl describe deploy myapp101-helmbasics-deployment
helm uninstall myapp101
```

## 5. Add one Builtin Object Chart.Name to labels
```yaml
# _helpers.tpl
{{/* Common Labels */}}
{{- define "helmbasics.labels"}}
    app: nginx
    chartname: {{ .Chart.Name }}
{{- end }}
```

## 6. Test the output with template action
```sh
# Helm Template Command
helm template myapp101 1-helm/lab7_11_named_templates/helmbasics

# Helm Install with dry-run command
helm install myapp101 1-helm/lab7_11_named_templates/helmbasics --dry-run

# Observation:
1. Chart name field should be empty
2. Chart Name was not in the scope for our defined template.
3. When a named template (created with define) is rendered, it will receive the scope passed in by the template call. 
4. No scope was passed in, so within the template we cannot access anything in "."
5. This is easy to fix. We simply pass a scope to the template
```

## 7. Pass scope to the template call
- Add dot "." (Root Object or period) at the end of template call to pass scope to template call
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}-deployment # Action Element
  labels:
  {{- template "helmbasics.labels" . }}
```

## 8. Test the output with template action when scope passed to template call
```sh
# Helm Template Command
helm template myapp101 1-helm/lab7_11_named_templates/helmbasics

# Helm Install with dry-run command
helm install myapp101 1-helm/lab7_11_named_templates/helmbasics --dry-run
Observation:
Chart Name should be displayed
```

## 9. Pipe an Upper function to template 
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}-deployment # Action Element
  labels:
  {{- template "helmbasics.labels" . | upper }}
```

## 10. Test the output when template action + pipe + upper function
```sh
# Helm Template Command
helm template myapp101 1-helm/lab7_11_named_templates/helmbasics

# Helm Install with dry-run command
helm install myapp101 1-helm/lab7_11_named_templates/helmbasics --dry-run

# Observation:
1. Should fail with error. What is the reason for failure ?
2. Template is an action, and not a function, there is no way to pass the output of a template call to other functions.
```

## 11. Replace Template action with Special Purpose include function
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}-deployment # Action Element
  labels:
  {{- include "helmbasics.labels" . | upper }}
```

## 12. Test the output include function
```yaml
# Helm Template Command
helm template myapp101 1-helm/lab7_11_named_templates/helmbasics

# Helm Install with dry-run command
helm install myapp101 1-helm/lab7_11_named_templates/helmbasics --dry-run
Observation:
1. Call include "helmbasics.labels" -- should be successful
2. Should show all labels in upper case
```

