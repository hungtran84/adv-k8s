# Blue/Green with Argo Rollouts
Our example application can be found at `https://github.com/hungtran84/argocd-example-app.git/tree/main/blue-green-app`.

It is a very simple application with one deployment and one service. Notice that the deployment has been converted to a Rollout and has an extra section about the blue/green deployment options.

## Install the Argo Rollouts controller
Before we get started with progressive delivery we need to install the Argo Rollouts controller on the cluster.

Login in the UI tab.

The UI starts empty because nothing is deployed on our cluster. Click the `"New app"` button on the top left and fill the following details:

```yaml
application name : argo-rollouts-controller
project: default
SYNC POLICY: automatic
AUTO-CREATE Namespace: enabled
repository URL: https://github.com/hungtran84/argocd-example-app.git
path: ./argo-rollouts-controller
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: argo-rollouts
Leave all the other values empty or with default selections. Finally click the Create button. The controller will be installed on the cluster.
```

>Notice that we are not using the default namespace, but a brand new one. It is imperative that you select the `"auto-create namespace"` option.
```yaml
auto-create
```

If you don't select this option, ArgoCD will not find the namespace and deployment will fail. Delete the application and create it again if you have a deployment issue.

You can also manually do if you forgot it in the UI:
```sh
kubectl create namespace argo-rollouts
```

Try syncing again the application.

You can see that GitOps is not only useful for your own applications but also for other supporting applications as well.

Wait some time until the controller is fully synced and the deployment is marked as Healthy.

## The first deployment
The Argo Rollouts controller is running now on the cluster and it is ready to handle deployments.

Lets deploy our application. Since this is the first deployment, there is no previous version and thus a normal deployment will take place.

Login in the UI tab.

Click the `"New app"` button on the top left and fill the following details
```yaml
application name : demo
project: default
SYNC POLICY: Manual
repository URL: https://github.com/hungtran84/argocd-example-app.git
path: ./blue-green-app
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: default
```
Leave all the other values empty or with default selections.

Finally click the Create button. The application entry will appear in the main dashboard. Click on it.


The application will be initially `"Out of Sync"`. Press the sync button to sync it and wait until it is healthy.

The application is deployed and you can see it in the `"Live traffic"` tab

Argo Rollouts also has an optional CLI that can be used for monitoring and promoting deployments

## Kubectl Plugin Installation

The kubectl plugin is optional, but is convenient for managing and visualizing rollouts from the command line.

`Brew`
```sh
brew install argoproj/tap/kubectl-argo-rollouts
```

`Manual`
Install Argo Rollouts Kubectl plugin with curl.

```sh
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-darwin-amd64
```

>[!Note] For Linux dist, replace darwin with linux

Make the kubectl-argo-rollouts binary executable.
```sh
chmod +x ./kubectl-argo-rollouts-darwin-amd64
```

Move the binary into your PATH.
```sh
sudo mv ./kubectl-argo-rollouts-darwin-amd64 /usr/local/bin/kubectl-argo-rollouts
```

Test to ensure the version you installed is up-to-date:
```sh
kubectl argo rollouts version
```

We can use the plugin to monitor the first deployment

Run the following
```sh
kubectl argo rollouts list rollouts  
kubectl argo rollouts status simple-rollout  
kubectl argo rollouts get rollout simple-rollout  
```

The last command shows the status of the rollout. Since this is the first version there is only one replicaset with two pods.

You can also see this with
```sh
kubectl get rs
```

## Blue/Green deployments
We are now ready to have a blue/Green deployment with the next version.

Change the container image of the rollout to the next version with:

```sh
kubectl argo rollouts set image simple-rollout webserver-simple=docker.io/100691080586/canary-app:v2.0
```

We are using kubectl just for illustration purposes. Normally you should follow the GitOps principles and perform a commit to the Git repo of the application. But just for this exercise we will do all actions manually so that you have time to see what happens.

Enter the following to see what Argo Rollouts is doing behind the scenes
```sh
kubectl argo rollouts get rollout simple-rollout
```

After you change the image the following things happen
  - Argo Rollouts creates another replicaset with the new version
  - The old version is still there and gets live/active traffic
  - ArgoCD will mark the application as out-of-sync
  - ArgoCD will also mark the health of the application as "suspended" because we have setup the new color to wait  

Notice that even though the next version of our application is already deployed, all live traffic goes to the old version. You can verify this by looking at the `"live traffic" `tab.

At this point the deployment is suspended because we have used the autoPromotionEnabled: false property in the definition of the rollout.

To manually promote the deployment and switch all traffic to the new version enter:
```sh
kubectl argo rollouts promote simple-rollout
```

Then monitor again the rollout with
```sh
kubectl argo rollouts get rollout simple-rollout --watch
```

After a while you should see the pods of the old version getting destroyed.

Now all live traffic goes to the new version as can be seen from the `"live traffic"` tab.

The deployment has finished successfully now.