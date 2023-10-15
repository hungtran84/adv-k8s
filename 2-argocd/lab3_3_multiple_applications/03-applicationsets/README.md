# Welcome
## Introduction
Our example application can be found at https://github.com/hungtran84/argocd-example-app/tree/master/application-sets

Make sure to fork it to your own account and note down the URL. It should be something like: `https://github.com/<your user>/argocd-example-app/`

The example folder contains

  - a set of Kubernetes manifests
  - several examples of application set resources
  - a starting folder that will be used for deployments

## Deploy an application multiple times
Login in the UI tab.

The UI starts empty because nothing is deployed on our cluster.

We will start deploying several application sets. Application sets can be used in several scenarios such

  - Deploying a single application to many namespaces
  - Deploying a single application to many clusters
  - Deploying many applications in a single cluster
  - Deploying many applications in many clusters
  - Application Sets are based on generators that create different ArgoCD applications in a massive way. 
  
Application Sets do not interact directly with the cluster or ArgoCD. They are just a factory for ArgoCD applications.

## Using the list generator
Let's see a simple example using the List generator. The list generator iterates over a list of resources and creates ArgoCD applications with each loop.

If you look at the starting example at `https://github.com/hungtran84/argocd-example-app/blob/master/application-sets/my-application-sets/single-app-many-times.yml` you will see we use namespaces as the iterator source.

```yaml
  generators:
  - list:
      elements:
      - namespace: team-a
      - namespace: team-b
      - namespace: team-c
      - namespace: staging
```  
This way we can deploy a single application to 4 namespaces without actually creating 4 application manifests by hand.

Let's do this now.

Create an Argo CD application (using the UI or CLI) with the following options:

```yaml
application name : my-application-sets
project: default
SYNC POLICY: auto
repository URL: https://github.com/<your user>/argocd-example-app
path: ./application-sets/my-application-sets/
Cluster: https://kubernetes.default.svc
Namespace: argocd
```

>Notice that because this is an ArgoCD application we deploy it on the argocd namespace so that ArgoCD can detect it. The applications themselves will be deployed on their own namespace as defined by their Application Resource as it will be created by the generator.

>Notice how ArgoCD shows both the children applications as well as the application set that generated them in the UI.

We now deployed a single application in 4 namespaces in a single step

## Deploy multiple applications at once
Using the list `generator` is great for starting out with application sets, but if you have a large number of applications it is always better to store them directly in Git as different files/folders than hardcoding them in a list.

This way you can `add/remove` application folders and have ArgoCD automatically `deploy/undeploy` applications (similar to app-of-apps).

Our second example at https://github.com/hungtran84/argocd-example-app/blob/master/application-sets/generators/many-apps.yml is doing exactly that with a Git generator.

  - it iterates over Git folders at application-sets/example-apps/*
  - it creates one ArgoCD application for each folder
  - it uses as target namespace the name of the last folder path `path.basename`

## Deploying multiple applications to a single cluster
Let's deploy this application set now.

In your own Github repo

- Copy the file `application-sets/generators/many-apps.yml` to `application-sets/my-application-sets`
- Optionally delete `application-sets/my-application-sets/single-app-many-times.yml` to remove the previous example
- Commit and push your changes. Refresh manually the `my-application-sets` application in UI instead of waiting for ArgoCD to pick up the changes.

Once ArgoCD detects the new application set it will deploy all 4 applications to their respective namespaces.