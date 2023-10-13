# Deploy application in a specific project
## 1. Use the exmpale file to create a argocd project
https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#projects

```yaml
# app-project.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: argocd-lab
  namespace: argocd
spec:
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  destinations:
  - namespace: helm-guestbook
    server: https://kubernetes.default.svc
  sourceRepos:
  - https://github.com/hungtran84/argocd-example-app.git

```
```
kubectl apply -f app-project.yaml 
```

## 2. Use the exmpale file to create a argocd application
```yaml
# application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: helm-guestbook
  namespace: argocd  
spec:
  destination:
    namespace: helm-guestbook
    server: https://kubernetes.default.svc
  project: argocd-lab
  revisionHistoryLimit: 5
  syncPolicy:
    automated:
      prune: true
      allowEmpty: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - ServerSideApply=true
  source:
    path: helm-guestbook
    repoURL: https://github.com/hungtran84/argocd-example-app.git
    helm:
      releaseName: helm-guestbook
      values: |
        # Default values for helm-guestbook.
        # This is a YAML-formatted file.
        # Declare variables to be passed into your templates.

        replicaCount: 1

        image:
          repository: gcr.io/heptio-images/ks-guestbook-demo
          tag: 0.1
          pullPolicy: IfNotPresent

        service:
          type: ClusterIP
          port: 80

        ingress:
          enabled: false
          annotations: {}
            # kubernetes.io/ingress.class: nginx
            # kubernetes.io/tls-acme: "true"
          path: /
          hosts:
            - chart-example.local
          tls: []
          #  - secretName: chart-example-tls
          #    hosts:
          #      - chart-example.local

        resources: {}
          # We usually recommend not to specify default resources and to leave this as a conscious
          # choice for the user. This also increases chances charts run on environments with little
          # resources, such as Minikube. If you do want to specify resources, uncomment the following
          # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
          # limits:
          #  cpu: 100m
          #  memory: 128Mi
          # requests:
          #  cpu: 100m
          #  memory: 128Mi

        nodeSelector: {}

        tolerations: []

        affinity: {}
```

```sh
kubectl apply -f application.yaml 
```

## 3. Remove the application and project
```sh
kubectl delete -f application.yaml
kubectl delete -f app-project.yaml
```
