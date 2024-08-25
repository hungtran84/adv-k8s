# nginx-ingress
To use, add ingressClassName: nginx spec field or the kubernetes.io/ingress.class: nginx annotation to your Ingress resources.

This chart bootstraps an ingress-nginx deployment on a  cluster using the  package manager.

## Requirements
Kubernetes: >=1.21.0-0

## Get Repo Info
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

## Install Chart
Important: only helm3 is supported

```
helm install nginx-ingress ingress-nginx/ingress-nginx
```