# Helm Development - Flow Control With 

## 1. Introduction
- `with` action controls variable scoping. 
- `with` action can allow you to set the current scope (.) to a particular object. 
### with action Syntax
```yaml
{{ with PIPELINE }}
  # restricted scope
{{ end }}
```
## 2. Review values.yaml
```yaml
# For testing Flow Control: with 
podAnnotations: 
  appName: myapp1
  appType: webserver
  appTech: HTML
```

## 3. Implement `"with"` action
- `with` action statement sets the dot obejct "." to `.Values.podAnnotations` 
- Inside the `with` action block dot "." always refers to `.Values.podAnnotations` 
- Outside the `with` action block dot "." refers to Root Object
```yaml
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}        
      {{- end }}    
```

## 4. Test the "with" action Implementation
```shell
# Helm Template
helm template myapp 1-helm/lab7_7_with/helmbasics

# Helm Install with dry-run
helm install myapp 1-helm/lab7_7_with/helmbasics --dry-run  

# Observation:
We should see all the annotations displayed
      annotations:
        appName: myapp1
        appTech: HTML
        appType: webserver
```

## 5. Try to access any Root Object in "with" action block
```yaml
# Add Root Object in with Block
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
        appManagedBy: {{ .Release.Service }}
      {{- end }}    
```

```sh
# Helm Template
helm template myapp 1-helm/lab7_7_with/helmbasics

# Helm Install with dry-run
helm install myapp 1-helm/lab7_7_with/helmbasics --dry-run  

# Observation:
1. It should throw an error and fail because .Release.Service is not inside of the restricted scope for . which refers to ".Values.podAnnotations". 

## Sample Error
Error: template: helmbasics/templates/deployment.yaml:23:33: executing "helmbasics/templates/deployment.yaml" at <.Release.Service>: nil pointer evaluating interface {}.Service
```

## 6. Add $ to Root Object
- To access Root Objects inside `with` action block we need to prepend that Root object with `$`
```yaml
# To Access Root Object
       appManagedBy: {{ $.Release.Service }}
```
```sh
# Helm Template
helm template myapp 1-helm/lab7_7_with/helmbasics

# Helm Install with dry-run
helm install myapp 1-helm/lab7_7_with/helmbasics --dry-run  

# Observation:
1. It should work as expected
      annotations:
        appName: myapp1
        appTech: HTML
        appType: webserver
        appManagedBy: Helm  
```

## 7. Scope more detailed for "with" action block
- How to retrieve a single object from `.Values.myapps.data.config` ?
- What if there is only need for 1 or 2 values from `.Values.myapps.data.config` ?
- How to access each key value from `.Values.myapps.data.config` ?
```yaml
# values.yaml
# For testing Flow Control: with - Scope more detailed
myapps:
  data: 
    config: 
      appName: myapp1
      appType: webserver
      appTech: HTML
      appDb: mysql

# Current Scope: Retrieve single object using scope
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
data: 
{{- with .Values.myapps.data.config }}
  application-name: {{ .appName }}
  application-type: {{ .appType }}
{{- end}}

```
```sh
# Helm Template
helm template myapp 1-helm/lab7_7_with/helmbasics

# Helm Install with dry-run
helm install myapp 1-helm/lab7_7_with/helmbasics --dry-run  

# Observation:
1. We should be able to get values for {{ .appName }} and {{ .appType }}
```