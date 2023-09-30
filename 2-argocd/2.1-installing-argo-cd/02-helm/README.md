# Prerequisites
The two essential items you need to ensure before installing Argo are
- [Kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [Helm](https://helm.sh/docs/intro/install/) installed

# Install Argo CD using HELM
Link to Argo CD source code: https://github.com/argoproj/argo-helm.git
```
git clone https://github.com/argoproj/argo-helm.git
```

Change the directory or the folder where you need to install Argo using helm charts 
```
cd argo-helm/charts/argo-cd/
```

Run the below command to create a namepsace (we have named argocd-helm) in the folder for argo installation
```
kubectl create ns argocd-helm
```

You can modify any custom values in values.yaml. But for now we will process using default values.yaml

Update the dependencies in the chart by executing the below command.
```
helm dependency up
```

Install argo using helm command 
```
helm install argocd-helm . -f values.yaml -n argocd-helm
```

Note if you come across the following error, please follow the subsequent steps. 

Error: rendered manifests contain a resource that already exists. Unable to continue with install: CustomResourceDefinition "applications.argoproj.io" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "argocd-helm"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "argocd-helm"
If you face the above issues with CRDs, then comment crds install value to ‘false’ in values.yaml. Refer to the below command.  
```
crds:
-- Install and upgrade CRDs
install: false
```

# Check the status of Argo CD installation
Once the installation is complete, let’s see the pods running 
```
kubectl get po -n argocd-helm
```

After ensuring the pods are running, then port-forward the Argo cd service to access the service from the browser. 
```
kubectl port-forward service/argocd-helm-server 8090:80 -n argocd-helm
```

You can now access the Argo CD UI from your browser by typing the following URL. http://localhost:8090

Very similar to the Argo CD installation using the manifest section, one has to get the password for the ‘admin’ password using the following command. 

Get the password from the new terminal using the below command.
```
kubectl -n argocd-helm get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```
Login to Argo CD UI using the username: admin and password.  

# Uninstall Argocd using HELM
You can simply follow the steps if you want to uninstall Argocd from your local machine. 

First, list the release name in your namespace
```
helm list  -n argocd-helm
NAME  NAMESPACE REVISION STATUS      CHART      APP VERSION
argocd-helm  argocd-helm   1  	   deployed  argo-cd-5.46.5	v2.8.4
```

Uninstall Argocd using the release name and namespace, using helm.
```
helm uninstall argocd-helm  -n argocd-helm
```
