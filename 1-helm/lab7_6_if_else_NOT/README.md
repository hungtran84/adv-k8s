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

## 2. Review values.yaml
```yaml
# If, else if, else
myapp:
  env: prod
```

## 3. Logic and Flow Control Function: `not` 
- [Logic and Flow Control Functions](https://helm.sh/docs/chart_template_guide/function_list/#logic-and-flow-control-functions)
- **not:**  Returns the boolean negation of its argument.
```t
# and Syntax
not .Arg
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
{{- if not (eq .Values.myapp.env "prod") }}
  replicas: 1
{{- else }}  
  replicas: 6
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
helm template myapp 1-helm/lab7_6_if_else_NOT/helmbasics --set myapp.env=prod
helm template myapp 1-helm/lab7_6_if_else_NOT/helmbasics --set myapp.env=dev
helm template myapp 1-helm/lab7_6_if_else_NOT/helmbasics --set myapp.env=null

# Helm Install Dry-run 
helm install myapp 1-helm/lab7_6_if_else_NOT/helmbasics --dry-run

# Helm Install
helm install myapp 1-helm/lab7_6_if_else_NOT/helmbasics --atomic

# Verify Pods
helm status myapp1 --show-resources

# Uninstall Release
helm uninstall myapp1
```
