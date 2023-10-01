# Prerequisites
The following tools need to be installed:
- Kubectl 
- ArgoCD CLI (https://argo-cd.readthedocs.io/en/stable/cli_installation)
- Yq (https://github.com/mikefarah/yq#install)

# 1. Get initial admin username - password
ArgoCD is created with an initial admin username and password, you can use the following command to retrieve it for the next step
```
ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD admin password: $ARGOCD_PWD"
```

# 2. Login to ArgoCD CLI
Setting the additional args for argocd cli
```
export ARGOCD_OPTS='--port-forward --port-forward-namespace argocd'
```

Login to argocd cli
```
argocd login --plaintext --username admin --password $ARGOCD_PWD
```

Expected outputs
```
'admin:login' logged in successfully
Context 'port-forward' updated
```

# 3. Create `alice` user
ArgoCD local user should be created using `argocd-cm` configMap. So we need to:
- Backup the current `argocd-cm` configMap
- Add a new `alice` user to `argocd-cm` configMap
- Apply the updated `argocd-cm` to GKE cluster

### Backup the current `argocd-cm` configMap
```
kubectl get configmap argocd-cm -n argocd -o yaml | yq eval 'del(.metadata.resourceVersion, .metadata.uid, .metadata.annotations, .metadata.creationTimestamp, .metadata.selfLink, .metadata.managedFields)' - > argocd-cm.yaml
```

The `yq` help us to remove unnecessary information out of the yaml file, so that our file will be export in the original format.

### Add new `alice` user
Open `argocd-cm.yaml` and add the following value under `data` path
```
accounts.alice: apiKey, login
```

The updated `argocd-cm.yaml` should look like this
```
apiVersion: v1
data:
  accounts.alice: apiKey, login
  admin.enabled: "true"
  application.instanceLabelKey: argocd.argoproj.io/instance
  exec.enabled: "false"
  server.rbac.log.enforce.enable: "false"
  timeout.hard.reconciliation: 0s
  timeout.reconciliation: 180s
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: argocd
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
    app.kubernetes.io/version: v2.6.6
    helm.sh/chart: argo-cd-5.46.5
  name: argocd-cm
  namespace: argocd
```

### Apply the updated `argocd-cm` configMap
```
kubectl apply -f argocd-cm.yaml
```

# 4. Set password for `alice`
### Get users
```
argocd account list
```
Output:
```
NAME   ENABLED  CAPABILITIES
admin  true     login
alice  true     apiKey, login
```

### Update `alice` password
> if you are managing users as the admin user, <current-user-password> should be the current admin password
```
$ALICE_PWD="abcd@1234"

argocd account update-password \
  --account alice \
  --current-password $ARGOCD_PWD \
  --new-password $ALICE_PWD
```