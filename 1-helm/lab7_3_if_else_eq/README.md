# Helm Development - Flow Control If-Else

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

## 2. Review `values.yaml`
```yaml
# If, else if, else
myapp:
  env: prod
```


## 3. Logic and Flow Control Function: `eq` 
- [Logic and Flow Control Functions](https://helm.sh/docs/chart_template_guide/function_list/#logic-and-flow-control-functions)
- **eq:**  Returns the boolean equality of the arguments (e.g., Arg1 == Arg2).
```yaml
# and Syntax
eq .Arg1 .Arg2
```

## 4. Implement if-else for replicas
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: nginx
spec:
{{- if eq .Values.myapp.env "prod" }}
  replicas: 4 
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
# Helm Template (when env: prod from values.yaml)
## TEST IF STATEMENT
helm template myapp1 1-helm/lab7_3_if_else_eq/helmbasics

# Helm Template (when env: qa using --set)
## TEST ELSE IF STATEMENT
helm template myapp1 1-helm/lab7_3_if_else_eq/helmbasics --set myapp.env=qa
 
# Helm Template (when env: dev or env: null using --set)
## TEST ELSE STATEMENT
helm template myapp1 1-helm/lab7_3_if_else_eq/helmbasics --set myapp.env=dev

# Helm Install Dry-run 
helm install myapp1 1-helm/lab7_3_if_else_eq/helmbasics --dry-run

# Helm Install
helm install myapp1 1-helm/lab7_3_if_else_eq/helmbasics --atomic

# Verify Pods
helm status myapp1 --show-resources

# Uninstall Release
helm uninstall myapp1
```
