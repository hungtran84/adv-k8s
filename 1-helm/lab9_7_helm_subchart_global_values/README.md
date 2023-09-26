# Helm Sub Charts - Use Global Values in Sub Charts
## 1 Introduction
- Managing Dependencies manually
- Define Global Values

## 2 Review Chart.yaml
```yaml
apiVersion: v2
name: parentchart
description: Learn Helm Dependency Concepts
type: application
version: 0.1.0
appVersion: "1.16.0"
dependencies:
- name: mychart4
  version: "0.1.0"
  repository: "file://charts/mychart4"
  alias: childchart4
  tags: 
    - frontend
- name: mychart2
  version: "0.4.0"
  repository: "file://charts/mychart2"
  alias: childchart2
  tags: 
    - backend
```

## 3. Pull charts using helm pull command 
- We are going to pull the charts to `parentchart/charts` directory using `helm pull` command
- Also ensure that those packages are untarred or unzipped
```sh
# Change Directory
cd 1-helm/lab9_7_helm_subchart_global_values/parentchart/charts/

# Helm Pull MyChart4
helm pull oci://ghcr.io/hungtran84/helm/mychart4 --version 0.1.0 --untar

# Helm Pull MyChart2
helm pull oci://ghcr.io/hungtran84/helm/mychart2 --version 0.4.0 --untar

```

## 4. To Build or Package Sub Charts
```sh
# Change to Chart Directory
cd parentchart

# Helm Dependency list
helm dependency list

## Sample Outout
NAME    	VERSION	REPOSITORY             	STATUS  
mychart4	0.1.0  	file://charts/mychart4 	unpacked
mychart2	0.4.0  	file://charts/mychart2	unpacked

# Helm Dependency Update / Build
helm dependency update

# Review charts folder
ls charts/

# Observation: you should find *.tgz files for both charts

# helm dep list should show status as OK
helm dep list

NAME    	VERSION	REPOSITORY            	STATUS
mychart4	0.1.0  	file://charts/mychart4	ok    
mychart2	0.4.0  	file://charts/mychart2	ok  

# Delete subchart tgz files
rm charts/*.tgz
```

## 5. Define Global value in Parent Chart values.yaml
- **File:** parentchart/values.yaml
```yaml
# Define Global Values
global:
  replicaCount: 4
```

## 6. Update Parent Chart and Sub Chart deployment.yaml
- **File:** parentchart/templates/deployment.yaml
- **File:** charts/mychart4/templates/deployment.yaml
- **File:** charts/mychart2/templates/deployment.yaml
```yaml
replicas: {{ .Values.global.replicaCount }}
```

## 7. Test Global Values
```sh
# Change to Chart Directory
cd parentchart

# Helm Install
helm install myapp1 . --atomic

# Verify Pods for all 3 charts
kubectl get pods

# Observation: 
# All 3 charts should spin 4 pods per each based on ".Values.global.replicaCount=4"

# helm uninstall
helm uninstall myapp1
```