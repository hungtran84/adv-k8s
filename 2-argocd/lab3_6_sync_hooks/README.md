# Welcome
## Introduction
Our example application can be found at https://github.com/hungtran84/argocd-example-app/tree/master/sync-hooks-waves

Make sure to fork it to your own account and note down the URL. It should be something like: `https://github.com/<your user>/argocd-example-app/`

The folder `sync-hooks-waves` contains 6 progressively more complex examples for controlling the order of resource deployment

We will examine each one of them in order to look at the different options for resource ordering in ArgoCD.

## Default Deployment Order
Looking at the example application  

You can login in the UI tab.

The UI starts empty because nothing is deployed on our cluster.

If you look at the [first example](https://github.com/hungtran84/argocd-example-app/tree/master/sync-hooks-waves/01-default-order) you will see that we have a standard application that consists of

  - a service
  - a deployment
  - a namespace

We want to deploy this application in the cluster and obviously the namespace should be deployed first as the other resources depend on it.

The default deployment order  

By default ArgoCD will do its best and guess the best deployment order for all resources. You can see the default resource order in the source code.

>Notice that the namespace is indeed deployed first.

Let's see this in action.

Create an Argo CD application (using the UI or CLI) with the following options

```yaml
application name : example01
project: default
SYNC POLICY: manual
repository URL: https://github.com/<your user>/argocd-example-app
path: ./sync-hooks-waves/01-default-order
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: example01
```

Click on the application card inside the Argo CD UI and sync the application manually. 

>Notice how ArgoCD creates the namespace first and then the deployment and the service as is the correct order.

### How sync phases works?

Each Argo CD sync operation comes in 3 phases
  - PreSync phase
  - Sync phase (the main phase)
  - PostSync phase  

You can assign different resources to each phase to fine-tune the order of deployment for each Kubernetes resource/manifest.

## Using the PreSync phase
One of the most common scenarios for application deployment is a task that needs to run before the main sync phase. An example would be a database upgrade with a new schema.

We can instruct ArgoCD to assign the DB upgrade to the pre-sync phase with the following annotation:

```yaml
 argocd.argoproj.io/hook: PreSync
```

Let's see it in action.

Create an Argo CD application (using the UI or CLI) with the following options

```yaml
application name : example02
project: default
SYNC POLICY: manual
repository URL: https://github.com/<your user>/argocd-example-app
path: ./sync-hooks-waves/02-presync-job
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: example02
```

If you look at the files inside the manifest folder you will notice the PreSync annotation in the `db-upgrade.yml` file.

You can use sync phase annotations in most Kubernetes resources, but usually they are assigned to Kubernetes Job and/or Argo Workflows.

Click on the application card inside the Argo CD UI and sync the application manually. 

>Notice how ArgoCD runs first the DB upgrade job and waits until it finishes before syncing the deployment and service.

## Deploying resources after a sync
Similar to the PreSync phase, you can also deploy resources in the PostSync phase which ArgoCD will run after the main sync phase is complete.

Some common examples are

  - Slack notifications
  - Smoke tests
  - Cleanup operations

If you take a look at resources at the next example we have a cleanup job at `https://github.com/hungtran84/argocd-example-app/blob/master/sync-hooks-waves/03-postsync-cleanup/cleanup.yml`

We want to run this after the sync phase.

## Using the PostSync annotation
Let's annotate the job first. In your own fork add the following two lines

```yaml
  annotations:
    argocd.argoproj.io/hook: PostSync
```

at the metadata section in the manifest `cleanup.yml`. Then commit and push your changes.

Finally deploy the application:

Create an Argo CD application (using the UI or CLI) with the following options

```yaml
application name : example03
project: default
SYNC POLICY: manual
repository URL: https://github.com/<your user>/argocd-example-app
path: ./sync-hooks-waves/03-postsync-cleanup
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: example03
```

Click on the application card inside the Argo CD UI and sync the application manually. 

>Notice how ArgoCD runs first the DB upgrade job then the main sync phase and finally the cleanup job

## Handle errors during sync

Apart from the PreSync, Sync and `PostSync` phases, ArgoCD also has an optional `SyncFail` phase that is only activated if the main Sync phase has any errors.

In the case Argo CD will apply/deploy all resources that are marked with the `SyncFail` annotation. Notice also that a failure in the Sync process will never execute any `PostSync` resources.

You can use the `SyncFail` annotations for several scenarios such as

  - send a slack message about the deployment failure
Revert some resources that need to be reverted after a failure
  - Cleanup resources that were reserved during the deployment

### Using the SyncFail phase

If you take a look at https://github.com/hungtran84/argocd-example-app/tree/master/sync-hooks-waves/04-handle-sync-fail you will find 2 new resources.

The `sync-failure.yml` manifest imitates a sync failure. The `slack-notify.yml` imitates a slack notification that happens only in the case of a sync failure.

Let's see it in action.

Create an Argo CD application (using the UI or CLI) with the following options

```yaml
application name : example04
project: default
SYNC POLICY: manual
repository URL: https://github.com/<your user>/argocd-example-app
path: ./sync-hooks-waves/04-handle-sync-fail
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: example04
```

Click on the application card inside the Argo CD UI and sync the application manually. 

>Notice how Argo CD will run the slack notification job after they sync process has failed. Also notice that our cleanup job (that had the PostSync annotation) was never executed.
