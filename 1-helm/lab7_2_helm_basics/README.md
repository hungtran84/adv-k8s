# Helm Template Functions and Pipelines

## 1 Introduction
1. Template Actions `{{ }}`
2. Action Elements `{{ .Release.Name }}`
3. `Quote` Function
4. Pipeline 
5. `default` Function
6. `lower` function
7. Controlling White Spaces `{{-  -}}`
7. `indent` function
8. `nindent` function
9. `toYaml`

## 2. Template Action "{{ }}"
- Anything in between Template Action `{{ .Chart.Name }}` is called Action Element
- Anything in between Template Action `{{ .Chart.Name }}` will be rendered by helm template engine and replace necessary values
- Anything outside of the template action will be printed as it is.
- Action elements defined inside the `{{ }}` will help us to retrieve data from other sources (example: `.Chart.Name`).


### 2 Invalid Action Element 
```yaml
# vim 1-helm/lab7_2_helm_basics/helmbasics/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  # Template Action with Action Elements
  name: {{ something }}-{{ .Chart.Name }}
```

- Render helm chart
```
$ helm template myapp101 1-helm/lab7_2_helm_basics/helmbasics  
 

Error: parse error at (helmbasics/templates/deployment.yaml:4): function "something" not defined

Use --debug flag to render out invalid YAML
```

- Revert the change

```shell
cp 1-helm/lab7_2_helm_basics/backup-files/final-deployment-file/deployment.yaml 1-helm/lab7_2_helm_basics/helmbasics/templates/deployment.yaml
```

## 3 Template Function: quote
```yaml
# Add Quote Function 
  annotations:    
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    # quote function
    app.kubernetes.io/managed-by: {{ quote .Release.Service }} 

```

```t
# Helm Template Command
helm template myapp101 1-helm/lab7_2_helm_basics/helmbasics

---
# Source: helmbasics/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  # Template Action with Action Elements
  name: myapp101-helmbasics
  labels:
    app: nginx
  annotations:    
    app.kubernetes.io/managed-by: Helm
    # quote function
    app.kubernetes.io/managed-by: "Helm" 
```


## 4. Pipeline
- Pipelines are an efficient way of getting several things done in sequence. 
- Inverting the order is a common practice in templates (.val | quote ) 
```yaml
# Add Quote Function with Pipeline
  annotations:    
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    # quote function
    app.kubernetes.io/managed-by: {{ quote .Release.Service }} 
    # quote function with pipeline
    app.kubernetes.io/managed-by: {{ .Release.Service | quote }}               
```

```t
# Helm Template Command
helm template myapp101 1-helm/lab7_2_helm_basics/helmbasics

# quote function with pipeline
app.kubernetes.io/managed-by: "Helm" 
```

## 5. Template Function: default and lower
- [default function](https://helm.sh/docs/chart_template_guide/function_list/#default)
  
```yaml
# values.yaml
releaseName: "newrelease101"
replicaCount: 3
```

```yaml
spec:
  # default function
  replicas: {{ default 2 .Values.replicaCount }} 
```


```shell
# Helm Template Command
helm template myapp101 1-helm/lab7_2_helm_basics/helmbasics

...
spec:
  # default function
  replicas: 2 
```

## 6. Controlling Whitespaces
- **{{- .Chart.name }}:**  If a hyphen is added before the statement, `{{- .Chart.name }}` then the leading whitespace will be ignored during the rendering
- **{{ .Chart.name -}}:** If a hyphen is added after the statement, `{{ .Chart.name -}}` then the trailing whitespace will be ignored during the rendering

```yaml
    # Controlling Leading and Trailing White spaces 
    leading-whitespace: "   {{- .Chart.Name }}    myapp72"
    trailing-whitespace: "   {{ .Chart.Name -}}    myapp72"
    leadtrail-whitespace: "   {{- .Chart.Name -}}    myapp72"    
```

```shell
# Helm Template Command
helm template myapp101 1-helm/lab7_2_helm_basics/helmbasics

...
    # Controlling Leading and Trailing White spaces 
    leading-whitespace: "helmbasics    myapp72"
    trailing-whitespace: "   helmbasicsmyapp72"
    leadtrail-whitespace: "helmbasicsmyapp72"
```


## 7. `indent` and `nindent` functions
- **indent:** The [indent function](https://helm.sh/docs/chart_template_guide/function_list/#indent) indents every line in a given string to the specified indent width. This is useful when aligning multi-line strings:
- **nindent:** The [nindent function](https://helm.sh/docs/chart_template_guide/function_list/#nindent) is the same as the indent function, but prepends a new line to the beginning of the string.

```yaml
    # indent function
    indenttest: "  {{- .Chart.Name | indent 4 -}}  "
    # nindent function
    nindenttest: "  {{- .Chart.Name | nindent 4 -}}  "
```

```shell
# Helm Template Command
helm template myapp101 1-helm/lab7_2_helm_basics/helmbasics    

...
    # indent function
    indenttest: "    helmbasics"
    # nindent function
    nindenttest: "
 helmbasics"
```


## 8. Template Function: `toYaml` 
- **toYaml:** 
- We can use [toYaml function](https://helm.sh/docs/chart_template_guide/function_list/#type-conversion-functions) inside the helm template actions to convert an object into YAML.
- Convert list, slice, array, dict, or object to indented yaml. 
```yaml
# values.yaml
# Resources for testing Template Function: toYaml 
resources: 
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

# deployment.yaml
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        resources: 
        {{- toYaml .Values.resources | nindent 10}}
```

```shell
# Helm Template Command
helm template myapp101 1-helm/lab7_2_helm_basics/helmbasics

# Helm Install with --dry-run
helm install myapp101 1-helm/lab7_2_helm_basics/helmbasics --dry-run

# Helm Install
helm install myapp101 1-helm/lab7_2_helm_basics/helmbasics --atomic

# List k8s Pods
kubectl get pods 

# Describe Pod
kubectl describe pod <POD-NAME>

# Helm Uninstall
helm uninstall myapp101
```