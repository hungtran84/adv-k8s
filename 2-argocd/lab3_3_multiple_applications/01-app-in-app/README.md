# Welcome
## Introduction
Our example application can be found [here](https://github.com/hungtran84/argocd-example-app.git/tree/master/app-of-apps)

Make sure to fork it to your own account and note down the URL. It should be something like: `https://github.com/<your user>/argocd-example-app/`

The folder `app-of-apps` contains the following:

- Some dummy manifests (reused by multiple applications)
- A set of Argo CD applications that are commonly installed in Kubernetes clusters
- A root application that contains all the above

## Deploy all apps
The first deployment  

Login in the UI tab.

The UI starts empty because nothing is deployed on our cluster.

If you look at the folder that has the applications you will see that we have already defined `7 applications` using the Argo Application CRD

For capacity reasons all the applications are completely dummy and point to the same manifest.

We want to deploy all these applications to the cluster. Normally you would have to deploy the applications one by one and this is a very time consuming process.

But Argo CD has the concept of `App of Apps`. This means that you can create an Argo CD application which points to other applications instead of Kubernetes manifests.

Let's do this now.

Create an Argo CD application (using the UI or CLI) with the following options

```yaml
application name : my-favorite-apps
project: default
SYNC POLICY: manual
repository URL: https://github.com/hungtran84/argocd-example-app
path: ./app-of-apps/my-app-list
Cluster: https://kubernetes.default.svc 
Namespace: argocd
```

>[!Note] 
>Notice that because this is an Argo CD application we deploy it on the argocd namespace so that Argo CD can detect it. The applications themselves will be deployed on their own namespace as defined by their Application CRD.

Sync the application manually

>Notice how Argo CD shows both the children applications as well as the parent application in the UI. While the parent app we manually created has a manual sync policy, the child apps have automatic sync policies. Changes in the child app manifests will trigger an auto synchronization, changes to the child app definitions will not becuase they are synced using our parent app.

We now deployed 7 applications in a single step.

## Managing child apps
See the hierarchy of applications  

If you click on the parent application in the Argo CD UI you will see all the individual applications it manages.

This way you can evaluate the health of all individual applications as well as their Kubernetes resources.

Managing application lifecycle and application drift
One of the strengths of the App of Apps model is that ArgoCD treats child applications as Kubernetes resources (because they are). It monitors their health and will detect any discrepancy. It will optionally resync them if you choose to do so (automatic sync, self-heal enabled).

Go ahead and delete one of the child applications either from the `Argo CD GUI or the CLI`.

You will see that Argo CD will show the parent application as `"out-of-sync"` exactly like a normal application.

It will also show you exactly which application is missing.

This gives you the guarantee that you know exactly what child applications are deployed and if they are healthy or not.

## Root App Deletion
Deleting all applications at once 

Apart from deploying all applications at once you can also remove them by removing the parent application

>[!Note]   
>This behavior is controlled by ArgoCD finalizers that work on both children apps and the root app.

Go ahead and delete the parent application from the UI or the CLI. After a while all applications (parent and children) will be removed and the cluster will be back to the empty state.

## Cluster boostrapping
Using Argo CD App of Apps during infrastructure provisioning  

It is important to mention that the root application is also an Argo CD application on its own. A manifest was generated for it that you can also see at `https://github.com/hungtran84/argocd-example-app/blob/main/app-of-apps/root-app/my-application.yml`

>Notice that in line 18 it points to the folder of the other applications (instead of Kubernetes manifests).

In your own GitHub fork edit the file and change line 16 from
```yaml
repoURL: https://github.com/hungtran84/argocd-example-app.git
```  
to  
```yaml
repoURL: https://github.com/<your user>/argocd-example-app.git
```
Commit and push your changes.

This way you will control what applications will be included.

## Re-deploy the root app
Let's redeploy again our applications but using your own manifest this time.

Do this with
```sh
kubectl apply -f https://raw.githubusercontent.com/<your user>/argocd-example-app/main/app-of-apps/root-app/my-application.yml -n argocd
```
We are using kubectl for brevity here but in a real application you would use Argo CD Autopilot or an IAC solution such as Terraform, Pulumi or Crossplane.

## Default Applications
Handle the root application with GitOps  

Ok, we are now ready to modify the default applications we installed. Right now the root application is only installed in a single cluster but imagine you had this application configured for multiple clusters.

We want to modify the application list in the most GitOps way possible. This means only with Git commits and without the need for either the Argo CD UI or CLI.

Modify the list of default applications  

As an example, your organization has now decided that all clusters should also have `Argo Workflows`
 
Remember that the root app is now monitoring `Repo https://github.com/<your user>/argocd-example-app` and the folder `app-of-apps/my-app-list` inside that repo. 
As soon as any application is `added/removed` in that folder, Argo CD will `auto-sync` it.

Add two additional applications there. Go to Github in your own fork of `argocd-example-app` and copy two more apps from `app-of-apps/more-apps` to `app-of-apps/my-app-list`. These are two extra manifests

`Commit and push` your changes.

You will soon see the extra two applications in your cluster. You can now add/remove default applications just by Git commits!