# ArgocD ApplicationSet
[ApplicationSet](https://argo-cd.readthedocs.io/en/stable/user-guide/application-set/)
## 1. Use the exmpale file to create a argocd ApplicationSet
```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: kustomize-guestbook-as
  namespace: argocd
spec:
  generators:
  - list:
      elements:
      - namespace: dev
      - namespace: test
      - namespace: uat
  template:
    metadata:
      # will generate applications with different names for example (dev-color-app, test-color-app, etc..)
      name: '{{namespace}}-kustomize-guestbook'
    spec:
      # applications will be in default project for argocd
      project: default
      source:
        repoURL: https://github.com/argoproj/argocd-example-apps
        targetRevision: HEAD
        path: kustomize-guestbook
      destination:
        # default cluster as destination, you can define multiple clusters in ArgoCD UI
        server: https://kubernetes.default.svc
        # will deploy to different namespaces as different destinations 
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: true
          allowEmpty: true
          selfHeal: true
        syncOptions:
        - CreateNamespace=true

```
```sh
kubectl apply -f application-set.yaml 
```

## 2. Remove the applicationset
```
kubectl delete -f application-set.yaml 
```