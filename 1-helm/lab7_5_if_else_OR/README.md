# Helm Development - Flow Control If-Else with OR Function

## 1. Introduction
-  We can use `if/else` for creating conditional blocks in Helm Templates
- **eq:** For templates, the operators (eq, ne, lt, gt, and, or and so on) are all implemented as functions. 
- In pipelines, operations can be grouped with parentheses ((, and )).
- [Additional Reference: Operators are functions](https://helm.sh/docs/chart_template_guide/functions_and_pipelines/#operators-are-functions)
### IF-ELSE Syntax
```yaml
{{ if PIPELINE }}
  # Do something
{{ else if OTHER PIPELINE }}
  # Do something else
{{ else }}
  # Default case
{{ end }}
```

## 2. Review values.yaml
```yaml
# If, else if, else
myapp:
  env: prod
```

## 3. Logic and Flow Control Function: `or` 
- [Logic and Flow Control Functions](https://helm.sh/docs/chart_template_guide/function_list/#logic-and-flow-control-functions)
- **or:**  Returns the boolean OR of two or more arguments (the first non-empty argument, or the last argument).
```yaml
# and Syntax
or .Arg1 .Arg2
```
## 4. Implement if-else for replicas with OR 

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: nginx
spec:
{{- if or (eq .Values.myapp.env "prod") (eq .Values.myapp.env "uat") }}
  replicas: 6
{{- else if eq .Values.myapp.env "qa" }}  
  replicas: 2
{{- else }}  
  replicas: 1  
{{- end }}
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

## 5. Verify if-else
```shell
# Helm Template 
helm template myapp1 1-helm/lab7_5_if_else_OR/helmbasics --set myapp.env=prod
helm template myapp1 1-helm/lab7_5_if_else_OR/helmbasics --set myapp.env=uat
helm template myapp1 1-helm/lab7_5_if_else_OR/helmbasics --set myapp.env=dev
helm template myapp1 1-helm/lab7_5_if_else_OR/helmbasics --set myapp.env=null


# Helm Install Dry-run 
helm install myapp1 1-helm/lab7_5_if_else_OR/helmbasics --dry-run

# Helm Install
helm install myapp1 1-helm/lab7_5_if_else_OR/helmbasics --atomic

# Verify Pods
helm status myapp1 --show-resources

# Uninstall Release
helm uninstall myapp1
```
