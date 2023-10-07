## Prerequisite
You need to have a GitHub account for this exercise.

The example application is at https://github.com/argoproj/argocd-example-apps/tree/master/kustomize-guestbook. Fork this repository in your own account

Make sure to fork it to your own account and note down the URL. It should be something like:

https://github.com/<your user>/argocd-example-apps/

Take a look at the Kubernetes manifests to understand what we will deploy. It is a very simple application with one deployment and one service

# Deployment
Login in the UI tab.

The UI starts empty because nothing is deployed on our cluster. Click the "New app" button on the top left and fill the following details:

```
application name : demo  
project: default  
repository URL: https://github.com/hungtran84/argocd-example-app.git  
path: helm-guestbook  
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)  
Namespace: default  
Leave all the other values empty or with default selections. Finally click the Create button. The application entry will appear in the main dashboard. Click on it.  
```

Now sync the application to make sure that it is deployed. 

You can also verify the application from the command line with:
```
kubectl get deployments
```

# Deploy a new version
We want to deploy another version of our application. We will change the Git and see how ArgoCD detects the change.

Perform a commit in your guestbook-ui-deployment.yaml file in your own account (You can use GitHub on another tab for this) and change the container tag at line 17 from :0.1 to :0.2

Normally ArgoCD checks the state between Git and the cluster every 3 minutes on its own. Just to speed things up you should click manually on the application in the ArgoCD dashboard and press the "Refresh" button

Here ArgoCD tells us that the Git state is no longer the same as the cluster state. From the yellow arrows you can see that the from all the Kubernetes components the deployment is now different. And thus the whole application is different.

You can click on the "App diff" button and see the exact change. Enable the "compact diff" checbox.

# Detecting cluster changes
Let's bring the cluster back to the same state as Git. Click the Sync button in the UI to make the application synced with the new version.

You can also execute the following from the CLI:
```
argocd app sync demo
argocd app wait demo
```

Detecting changes in Git and applying is a well known scenario. The big strength of GitOps, is that ArgoCD works in the opposite direction as well. If you make any change in the cluster then ArgoCD will detect it and again tell you that something is different between Git and your cluster.

Let's say that somebody changes manually the replicas of the deployment without creating an official Pull Request (a bad practice in general).

Execute the following
```
kubectl scale --replicas=3 deployment guestbook-ui
```

Normally ArgoCD checks the state between Git and the cluster every 3 minutes on its own. Just to speed things up you should click manually on the application in the ArgoCD dashboard and press the "Refresh" button. The click the "App diff" button and enable the "Compact Diff" checkbox.

ArgoCD again detects the change between the two states. This capability is very powerful and you can easily detect configuration drift between your environments.