# Install ArgoCD using manifests
## Requirements
- Installed `kubectl` command-line tool.
- Have a kubeconfig file (default location is` ~/.kube/config`).

## Install Argo CD into using manifest
We will start to Install Argo CD applications by creating a namespace first. 

Run the command to create a namespace (we have used argocd-manifest).  
```sh
kubectl create namespace argocd-manifest
```

Install argo to the argocd-manifest created namespace.
```sh
kubectl apply -n argocd-manifest -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Get the password of the Argo CD application, for ‘admin’ username, by executing the below command.
```sh
kubectl -n argocd-manifest get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

## Check the status of Argo CD installation
- Once the installation is complete, let’s see the pods running 
```sh
kubectl get pod -n argocd-manifest
``` 

- After ensuring the pods are running, then port-forward the Argo cd service to access the service from the browser. 
```sh
kubectl port-forward service/argocd-server 8090:80 -n argocd-manifest
``` 

You can now access the Argo CD UI from your browser by typing the following URL. http://localhost:8090 

Login to Argo CD UI using the username: admin and password.

## Uninstall Argo CD installation
Delete the namespace
```sh
kubectl delete namespace argocd-manifest
```
