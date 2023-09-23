# Helm Builtin Objects

## 1. Introduction
- Objects are passed into a template from the template engine. 
- Objects can be simple, and have just one value or they can contain other objects or functions. 
- For example: the Release object contains several objects (like .Release.Name) and the Files object has a few functions.
### Helm Builtin Objects
- Release 
- Chart 
- Values 
- Capabilities 
- Template 
- Files 

## 2. Create a simple chart and clean-up NOTES.txt
```shell
# Create Helm Chart
helm create builtinobjects

# Remove all content from NOTES.txt
cat /dev/null > builtinobjects/templates/NOTES.txt

# helm install --dry-run
helm install myapp1 . --dry-run
```

## 3. Helm Object: Root or dot or Period (.)
```t
# vim builtinobjects/templates/NOTES.txt
{{/* Root or Dot or Period Object */}}
Root Object: {{ . }}
```

```
# helm install with --dry-run
helm install myapp1 builtinobjects  --dry-run

...
NOTES:
Root Object: map[Capabilities:0x14000908510 Chart:{{builtinobjects  [] 0.1.0 A Helm chart for Kubernetes [] []  v2   1.16.0 false map[]  [] application} true} Files:map[.helmignore:[35 32 80 97 116 116 101 114 110 115 32 116 111 32 105 103 110 111 114 101 32 119 104 101 110 32 98 117 105 108 100 105 110 103 32 112 97 99 107 97 103 101 115 46 10 35 32 84 104 105 115 32 115 117 112 112 111 114 116 115 32 115 104 101 108 108 32 103 108 111 98 32 109 97 116 99 104 105 110 103 44 32 114 101 108 97 116 105 118 101 32 112 97 116 104 32 109 97 116 99 104 105 110 103 44 32 97 110 100 10 35 32 110 101 103 97 116 105 111 110 32 40 112 114 101 102 105 120 101 100 32 119 105 116 104 32 33 41 46 32 79 110 108 121 32 111 110 101 32 112 97 116 116 101 114 110 32 112 101 114 32 108 105 110 101 46 10 46 68 83 95 83 116 111 114 101 10 35 32 67 111 109 109 111 110 32 86 67 83 32 100 105 114 115 10 46 103 105 116 47 10 46 103 105 116 105 103 110 111 114 101 10 46 98 122 114 47 10 46 98 122 114 105 103 110 111 114 101 10 46 104 103 47 10 46 104 103 105 103 110 111 114 101 10 46 115 118 110 47 10 35 32 67 111 109 109 111 110 32 98 97 99 107 117 112 32 102 105 108 101 115 10 42 46 115 119 112 10 42 46 98 97 107 10 42 46 116 109 112 10 42 46 111 114 105 103 10 42 126 10 35 32 86 97 114 105 111 117 115 32 73 68 69 115 10 46 112 114 111 106 101 99 116 10 46 105 100 101 97 47 10 42 46 116 109 112 114 111 106 10 46 118 115 99 111 100 101 47 10]] Release:map[IsInstall:true IsUpgrade:false Name:myapp1 Namespace:default Revision:1 Service:Helm] Subcharts:map[] Template:map[BasePath:builtinobjects/templates Name:builtinobjects/templates/NOTES.txt] Values:map[affinity:map[] autoscaling:map[enabled:false maxReplicas:100 minReplicas:1 targetCPUUtilizationPercentage:80] fullnameOverride: image:map[pullPolicy:IfNotPresent repository:nginx tag:] imagePullSecrets:[] ingress:map[annotations:map[] className: enabled:false hosts:[map[host:chart-example.local paths:[map[path:/ pathType:ImplementationSpecific]]]] tls:[]] nameOverride: nodeSelector:map[] podAnnotations:map[] podSecurityContext:map[] replicaCount:1 resources:map[] securityContext:map[] service:map[port:80 type:ClusterIP] serviceAccount:map[annotations:map[] create:true name:] tolerations:[]]]
```

## 4. Helm Object: Release
- This object describes the Helm release. 
- It has several objects inside it related to Helm Release.
- Put the below in `NOTES.txt` and test it

```t
# vim builtinobjects/templates/NOTES.txt
{{/* Release Object */}}
Release Name: {{ .Release.Name }}
Release Namespace: {{ .Release.Namespace }}
Release IsUpgrade: {{ .Release.IsUpgrade }}
Release IsInstall: {{ .Release.IsInstall }}
Release Revision: {{ .Release.Revision }}
Release Service: {{ .Release.Service }}

# Helm Install with --dry-run
helm install myapp1 builtinobjects  --dry-run

# Sample Output
NOTES:
Release Name: myapp1
Release Namespace: default
Release IsUpgrade: false
Release IsInstall: true
Release Revision: 1
Release Service: Helm
```

## 5. Helm Object: Chart
- Any data in Chart.yaml will be accessible using Chart Object. 
- For example {{ .Chart.Name }}-{{ .Chart.Version }} will print out the builtinobjects-0.1.0.
- [Complete Chart.yaml Objects for reference](https://helm.sh/docs/topics/charts/#the-chartyaml-file)
- Put the below in `NOTES.txt` and test it
```t
# vim builtinobjects/templates/NOTES.txt
{{/* Chart Objet */}}
Chart Name: {{ .Chart.Name }}
Chart Version: {{ .Chart.Version }}
Chart AppVersion: {{ .Chart.AppVersion }}
Chart Type: {{ .Chart.Type }}
Chart Name and Version: {{ .Chart.Name }}-{{ .Chart.Version }}

# Helm Install with --dry-run
helm install myapp1 builtinobjects  --dry-run

# Sample Output
Chart Name: builtinobjects
Chart Version: 0.1.0
Chart AppVersion: 1.16.0
Chart Type: application
Chart Name and Version: builtinobjects-0.1.0
```

## 6. Helm Objects: Values, Capabilities, Template
- **Values Object:** Values passed into the template from the values.yaml file and from user-supplied files. By default, Values is empty.
- **Capabilities Object:** This provides information about what capabilities the Kubernetes cluster supports
- **Template Object:** Contains information about the current template that is being executed
- Put the below in `NOTES.txt` and test it
```t
# vim builtinobjects/templates/NOTES.txt
{{/* Values Object */}}
Replica Count: {{ .Values.replicaCount }}
Image Repository: {{ .Values.image.repository }}
Service Type: {{ .Values.service.type }}

{{/* Capabilities Object */}}
Kubernetes Cluster Version Major: {{ .Capabilities.KubeVersion.Major }}
Kubernetes Cluster Version Minor: {{ .Capabilities.KubeVersion.Minor }}
Kubernetes Cluster Version: {{ .Capabilities.KubeVersion }} and {{ .Capabilities.KubeVersion.Version }}
Helm Version: {{ .Capabilities.HelmVersion }}
Helm Version Semver: {{ .Capabilities.HelmVersion.Version }}

{{/* Template Object */}}
Template Name: {{ .Template.Name }} 
Template Base Path: {{ .Template.BasePath }}

# Helm Install with --dry-run
helm install myapp1 builtinobjects  --dry-run

# Sample Output
Replica Count: 1
Image Repository: nginx
Service Type: ClusterIP


Kubernetes Cluster Version Major: 1
Kubernetes Cluster Version Minor: 27
Kubernetes Cluster Version: v1.27.3-gke.100 and v1.27.3-gke.100
Helm Version: {v3.12.2 1e210a2c8cc5117d1055bfaa5d40f51bbc2e345e clean go1.20.6}
Helm Version Semver: v3.12.2


Template Name: builtinobjects/templates/NOTES.txt 
Template Base Path: builtinobjects/templates
```

## 7. Helm Objects: Files
- **Files Object:** 
- Put the below in `NOTES.txt` and test it
- [Additional Reference: Access Files Inside Templates](https://helm.sh/docs/chart_template_guide/accessing_files/)
```t
# vim builtinobjects/templates/NOTES.txt
{{/* File Object */}}
File Get: {{ .Files.Get "myconfig1.toml" }}
File Glob as Config: {{ (.Files.Glob "config-files/*").AsConfig }}
File Glob as Secret: {{ (.Files.Glob "config-files/*").AsSecrets }}
File Lines: {{ .Files.Lines "myconfig1.toml" }}
File Lines: {{ .Files.Lines "config-files/myconfig2.toml" }}
File Glob: {{ .Files.Glob "config-files/*" }}

# Copy the configuration files to your helm chart 
cp -R 1-helm/lab7_1_helm_built_in-objects/files-demo builtinobjects

# Helm Install with --dry-run
helm install myapp1 builtinobjects  --dry-run

# Sample Output
File Get: message1 = Hello from config 1 line1
message2 = Hello from config 1 line2
message3 = Hello from config 1 line3

File Glob as Config: myconfig2.toml: |-
  appName: myapp2
  appType: db
  appConfigEnable: true
myconfig3.toml: |-
  appName: myapp3
  appType: app
  appConfigEnable: false
File Glob as Secret: myconfig2.toml: YXBwTmFtZTogbXlhcHAyCmFwcFR5cGU6IGRiCmFwcENvbmZpZ0VuYWJsZTogdHJ1ZQ==
myconfig3.toml: YXBwTmFtZTogbXlhcHAzCmFwcFR5cGU6IGFwcAphcHBDb25maWdFbmFibGU6IGZhbHNl
File Lines: [message1 = Hello from config 1 line1 message2 = Hello from config 1 line2 message3 = Hello from config 1 line3 ]
File Lines: [appName: myapp2 appType: db appConfigEnable: true]
File Glob: map[config-files/myconfig2.toml:[97 112 112 78 97 109 101 58 32 109 121 97 112 112 50 10 97 112 112 84 121 112 101 58 32 100 98 10 97 112 112 67 111 110 102 105 103 69 110 97 98 108 101 58 32 116 114 117 101] config-files/myconfig3.toml:[97 112 112 78 97 109 101 58 32 109 121 97 112 112 51 10 97 112 112 84 121 112 101 58 32 97 112 112 10 97 112 112 67 111 110 102 105 103 69 110 97 98 108 101 58 32 102 97 108 115 101]]
```

## Additional Reference
- [Helm Built-In Objects](https://helm.sh/docs/chart_template_guide/builtin_objects/)
- [Helm Chart.yaml Fields](https://helm.sh/docs/chart_template_guide/builtin_objects/)
