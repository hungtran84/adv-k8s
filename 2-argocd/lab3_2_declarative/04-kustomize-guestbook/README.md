# Deploy application using kustomize
## 1. Use the example file to create a argocd application
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kustomize-guestbook 
  namespace: argocd  
spec:
  destination:
    namespace: kustomize-guestbook
    server: https://kubernetes.default.svc
  project: default
  revisionHistoryLimit: 5
  syncPolicy:
    automated:
      prune: true
      allowEmpty: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
  source:
    path: kustomize-guestbook
    repoURL: https://github.com/hungtran84/argocd-example-app.git
```
```sh
kubectl apply -f application.yaml 
```

## 2. Remove the application
```sh
kubectl delete -f application.yaml 
```