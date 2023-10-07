## Prerequisites
The following tools need to be installed:
- Kubectl 
- ArgoCD CLI (https://argo-cd.readthedocs.io/en/stable/cli_installation)
- Yq (https://github.com/mikefarah/yq#install)

## 1. Built-in role
ArgoCD has two pre-defined roles but RBAC configuration allows defining roles and groups (see below).

- `role:readonly` - read-only access to all resources
- `role:admin` - unrestricted access to all resources

These default built-in role definitions can be seen in [builtin-policy.csv](https://github.com/argoproj/argo-cd/blob/master/assets/builtin-policy.csv)

## 2. Custom role
Assume that we already logged in to argocd cli as in `01-Create Local user`

ArgoCD RBAC is configured using `argocd-rbac-cm` configMap. So we need to:
- Backup the current `argocd-rbac-cm` configMap
- Add new custom RBAC policy under `data.policy.csv` path
- Apply the updated `argocd-rbac-cm` to GKE cluster

### Backup the current `argocd-rbac-cm` configMap
```
kubectl get configmap argocd-rbac-cm -n argocd -o yaml | yq eval 'del(.metadata.resourceVersion, .metadata.uid, .metadata.annotations, .metadata.creationTimestamp, .metadata.selfLink, .metadata.managedFields)' - > argocd-rbac-cm.yaml
```

### Define custom RBAC policy
We will define the following policy:
- Full access to Application (short way)
- Full access to ApplicationSet (short way)
- Readonly access to Logs
- Full access to Repositories (Long way)
- Full access to Project (Long way)

Below is the policy in ArgoCD format
```
p, role:developers, applications, *, */*, allow
p, role:developers, applicationsets, *, */*, allow
p, role:developers, repositories, get, *, allow
p, role:developers, repositories, create, *, allow
p, role:developers, repositories, update, *, allow
p, role:developers, repositories, delete, *, allow
p, role:developers, projects, get, *, allow
p, role:developers, projects, create, *, allow
p, role:developers, projects, update, *, allow
p, role:developers, projects, delete, *, allow
p, role:developers, logs, get, *, allow

g, alice, role:developers
```

### Add new custom policy to `argocd-rbac-cm` configMap
- Add the above policy under `data.policy.csv` path
```
g, alice, role:developers
```

```sh
kubectl -n argocd edit configmaps argocd-rbac-cm
```
The updated `argocd-rbac-cm.yaml` should look like this

```yaml
apiVersion: v1
data:
  policy.csv: |
    p, role:developers, applications, *, */*, allow
    p, role:developers, applicationsets, *, */*, allow
    p, role:developers, repositories, get, *, allow
    p, role:developers, repositories, create, *, allow
    p, role:developers, repositories, update, *, allow
    p, role:developers, repositories, delete, *, allow
    p, role:developers, projects, get, *, allow
    p, role:developers, projects, create, *, allow
    p, role:developers, projects, update, *, allow
    p, role:developers, projects, delete, *, allow
    p, role:developers, logs, get, *, allow
    g, alice, role:developers
  policy.default: ""
  scopes: '[groups]'
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: argocd
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: argocd-rbac-cm
    app.kubernetes.io/part-of: argocd
    app.kubernetes.io/version: v2.6.6
    helm.sh/chart: argo-cd-5.46.5
  name: argocd-rbac-cm
  namespace: argocd
```

## 3. Test the `alice` user via ArgoCD UI
### Port Forwarding
Since our ArgoCD instance is still not public to the outside via any method, we need to do the port-forward it to our localhost to access it
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Access ArgoCD Web UI
Open the web browser and enter the following address to access the ArgoCD Web UI
```
http://localhost:8080
```

After that, enter the following username / password to login to the ArgoCD
- Username: ***alice***
- Password: ***

### Test permission
Try to visit the following page:
- Settings --> Repository certificates and known hosts
    - Result: `ACCESS DENIED`
    - Reason: `alice` does not have `certificates` permission
- Settings --> GnuPG keys
    - Result: `ACCESS DENIED`
    - Reason: `alice` does not have `gpgkeys` permission
- Settings --> Projects --> NEW PROJECT
    - Result: `SUCCESS`
    - Reason: `alice` has `projects` full access
