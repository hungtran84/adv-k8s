# Diff Strategies in Argo CD

Our example application can be found at https://github.com/hungtran84/argocd-example-app/tree/master/custom-diff

Make sure to fork it to your own account and note down the URL. It should be something like: `https://github.com/<your user>/argocd-example-app/`

The folder `custom-diff` contains the following:

- One application that has a Horizontal Pod Autoscaler
- One application with a problematic Helm chart
- A folder with Argo CD manifests for the above

## Deploy some problematic apps
You can login in the UI tab.

The UI starts empty because nothing is deployed on our cluster.

If you look at the folder that has the applications you will see that we have already defined the 2 example application as Argo CD manifests

Let's deploy them now.

Create an Argo CD application (using the UI or CLI) with the following options

```yaml
application name : problematic-apps
project: default
SYNC POLICY: auto
repository URL: https://github.com/<your user>/argocd-example-app/
path: ./custom-diff/applications
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: argocd
```

>Notice that because this is an ArgoCD application we deploy it on the argocd namespace so that ArgoCD can detect it. The applications themselves will be deployed on their own namespace as defined by their Application CRD.

Wait for the root application to sync itself and notice that the children applications have also appeared in the Argo CD dashboard.

## Problem 1 - the HPA app
Let's focus on the first example application `hpa-example01`. Click on it in the Argo CD UI and then sync it. After the sync is complete, find the `"Refresh"` button in Argo CD , click on the small triangle on the right and the select `"Hard Refresh"` from the drop-down menu.

The application will become instantly out of sync.

### Having a variable number of replicas
The problem with this application is that it is using a Pod Autoscaler. The autoscaler is monitoring the application and will automatically change the number of its replicas. This means that it is impossible to have a fixed value of replicas in the Git repository as it is completely variable.

The end result is that ArgoCD will always show this application out of sync as the number of replicas that is live in the cluster will not match what is defined in Git.

The correct solution here would be to remove the replica definition from the deployment, but this is a contrived example to demonstrate applications that are always out of sync.

### Fix the HPA application
To solve the replica problem we need to instruct Argo CD to ignore that field during the diff process.

To do that edit the file `https://github.com/<your user>/argocd-example-app/blob/main/custom-diff/applications/with-hpa.yml` and add the following yaml segment at the end of the file

```yaml
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas
```

Remember The applications are defined under `/custom-diff/applications`. Both applications there should be pointing to your forked git repo and not to the example repo for this exercise.

This instructs Argo CD to ignore the replicas field in all deployments that are part of the application. Commit and push your changes.

If you now `sync/refresh` again the `hpa-example01` application it should sync with success.

## Problem 2 - the Helm app
Let's focus now on the second example application `helm-example02`. Click on it in the Argo CD UI and then sync it. After the sync is complete, find the "Refresh" button in Argo CD , click on the small triangle on the right and the select "Hard Refresh" from the drop-down menu.

The application will become instantly out of sync.

### Dealing with external applications
If an application has diff issues and it is fully under your control it is best to fix the app itself, instead of ignoring fields with Argo CD. But this is not always possible.

There are several existing applications from 3rd parties that have sync issues and they are not directly under your control. The example Helm application is using a random function for a password (that was present in the Redis chart in the past) and also has an annotation that is using a dynamic value that changes each time you deploy it.

So this application has two problems during the diff process.

### Fix the Helm application
To solve the diff problem with the Helm application we need to instruct Argo CD to ignore the problematic fields during the diff process.

Examine the files:

https://github.com/hungtran84/argocd-example-app/blob/master/custom-diff/02-external-app/templates/deployment.yml 

and 

https://github.com/hungtran84/argocd-example-app/blob/master/custom-diff/02-external-app/templates/secret.yml

to understand exactly what fields need to be ignored.

Then edit the file `https://github.com/<your user>/argocd-example-app/blob/master/custom-diff/applications/external-helm-app.yml` 

and add the required `ignoreDifferences` properly in the file.

Commit and push your changes.

If you now `sync/refresh` again the `helm-example02` application it should sync with success.