# Deploy application with Kustomize using ArgoCD
Our example application can be found [here](https://github.com/hungtran84/argocd-example-app/tree/master/kustomize-app)

Take a look at the base and overlays folders to understand what we will deploy. It is a very simple application with 2 environments to deploy to: `staging` and `production`.

The environments differ in several aspects such as number of replicas, database used, networking etc.

## Using the ArgoCD GUI
Login in the UI tab.

The UI starts empty because nothing is deployed on our cluster. Click the **NEW APP** button on the top left and fill the following details:

```
application name : kustomize-example
project: default
sync policy: automatic
repository URL: https://github.com/hungtran84/argocd-example-app.git
path: ./kustomize-app/overlays/staging
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: default
Leave all the other values empty or with default selections. Finally click the Create button. The application entry will appear in the main dashboard. Click on it.
```

Leave all the other values empty or with default selections. Finally click the Create button. The application entry will appear in the main dashboard. Click on it.

# Using ArgoCD CLI
Apart from the UI, ArgoCD also has a CLI. We have installed already the cli for you and authenticated against the instance.

Try the following commands
```sh
argocd app list
argocd app get kustomize-example
argocd app history kustomize-example
```

Let's delete the application and deploy it again but from the CLI this time.

First delete the app

```sh
argocd app delete kustomize-example -y
```

Now deploy it again.
```sh
argocd app create demo \
--project default \
--repo https://github.com/hungtran84/argocd-example-app.git \
--path ./kustomize-app/overlays/staging \
--sync-policy auto \
--dest-namespace default \
--dest-server https://kubernetes.default.svc
```

The application will appear in the ArgoCD dashboard.

Confirm the deployment
```
kubectl get all
```
