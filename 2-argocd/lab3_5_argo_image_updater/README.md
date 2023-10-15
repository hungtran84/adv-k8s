# Welcome
## Introduction
Our example application can be found at https://github.com/hungtran84/argocd-example-app/tree/master/image-updater

Make sure to fork it to your own account and note down the URL. It should be something like: `https://github.com/<your user>/argocd-example-app/`

The folder image-updater contains the following

  - Kustomize manifests for an application deployed in two environments (QA and Staging)  
  - A set of argoCD applications with different update strategies  
  - Installation manifest for Argo Image Updater with the interval period set to 1 minute (instead of 2)  
  - Source code for a trivial application that we will use for creating new Docker images and pushing them to Github packages

## Create the first container image
Introduction  

The example repository contains a [workflow](https://github.com/hungtran84/argocd-example-app/blob/master/.github/workflows/docker-publish.yml) for GitHub actions that

  - Takes as input a docker tag
  - Builds a docker image for a simple application
  - Pushes the image to the GitHub container registry

### Creating the initial release
Go to the Github UI of your forked repo and select the `"Actions"` section at the top navigation bar. Click the big green button that says `"I understand my workflows, go ahead and enable them"`

Select the `"Push Docker Image"` workflow from the left sidebar and click the "Run workflow" button on the right. Enter `1.0` for a tag

Create tag

Wait for some minutes until GitHub actions queues the workflow and then runs it. After the workflow runs you should now have the first image visible in the packages section of your repo.

View tag

The name of the image should be `ghcr.io/<your user>/argocd-example-app:1.0`

Make sure that the image is public. If you made your forked repo private for any reason, then all packages wil also be private and argo image updater will never find them.

To verify that image is public run the following on the terminal

```sh
docker logout ghcr.io
docker pull ghcr.io/<your user>/argocd-example-app:1.0
```

This command should finish with success

You can also verify that the image was pulled successfully with
```sh
docker image list | grep ghcr.io
```

### Perform the initial deployments
You can login in the UI tab.

The UI starts empty because nothing is deployed on our cluster. We will deploy two applications with different update strategies

The first application will always update the container image to the newly build tag
The second application will use semantic versioning only for `1.x` releases
We will use the app-of-apps pattern to deploy them both.

Updating the manifests for your own forked Repo
Before deploying the apps we need to make the manifests use your own image that we created in the previous step.

In all cases you need to change with your own Github user. Change the following files:

  - container tag in `image-updater/example-app/envs/qa/version.yml`
  - container tag in `image-updater/example-app/envs/staging/version.yml`
  - repoURL in `image-updater/applications/always-latest.yml`
  - argocd-image-updater.argoproj.io/image-list annotation in `image-updater/applications/always-latest.yml`
  - repoURL in `image-updater/applications/semver.yml`
  - argocd-image-updater.argoproj.io/image-list annotation in `image-updater/applications/semver.yml`

Commit and push your changes to your forked repo.

### Deploying the applications
We are now ready to deploy the applications. Create an Argo CD application (using the UI or CLI) with the following options

```yaml
application name : my-example-apps
project: default
SYNC POLICY: automatic
repository URL: https://github.com/<your user>/argocd-example-app
path: ./image-updater/applications
Cluster: https://kubernetes.default.svc
Namespace: argocd
```

Then `sync manually` both children apps.

We have `disabled auto-sync` on purpose on the child apps so that you can review the effect that Argo Image updater has on the manifests later in the exercise.

## Install Argo Image Updater
If you look at the application manifests for the two applications you will see the following annotations.

Application `always-latest01`
```yaml
argocd-image-updater.argoproj.io/image-list: example=ghcr.io/<your user>/argocd-example-app
argocd-image-updater.argoproj.io/example.update-strategy: latest
```

This means that the first application (deployed on the qa namespace) will always be updated to any image that is built regardless of its tag name. Argo Image updater will monitor the GitHub registry and as soon any new image is built, it will update the application manifest.

Application `follow-semver02`

```yaml
argocd-image-updater.argoproj.io/image-list: ghcr.io/<your user>/argocd-example-app:~1
```

This means that the second application (deployed on the staging namespace) will follow a semver strategy (which is the default strategy) but only for 1.x tags. Argo Image updater will monitor the GitHub registry and as soon any 1.x image is built that is larger than the current one, it will update the application manifest.

These annotations have no effect right now because the Argo Image Updater controller is not installed on our cluster.

### Installing Argo Image updater
We will install Argo Image updater from the `<your user>` repo so that we have a pinned/known version of the controller.

Create an Argo CD application (using the UI or CLI) with the following options

```yaml
application name : image-updater
project: default
SYNC POLICY: automatic
repository URL: https://github.com/hungtran84/argocd-example-app
path: ./image-updater/controller
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: argocd
```

>Notice that we install the controller on the same namespace as ArgoCD so that Image updater can notify it for manifest changes. Image Updater can also commit back to Git, but for simplicity reasons we will use the direct Argo CD integration.

After the application is synced you can see the logs in the ArgoCD UI to follow what the Image Updater is doing (it will wake up every minute and check for new container images.)

Right now there is only one published image in your repository (the `1.0` tag) so Argo Image Updater takes no action as both applications already use it.

## Release an RC version
We can now see image updater in action.

We will release a new container tag with the name `"rc2"`

After we release it we expect the following

The `"always-latest"` application will use it right away
The `"follow-semver"` application will do nothing as `"rc2"` is not a valid semver release  

Let's do this now

### Create a new container tag called "rc2"
Go to the Github UI of your forked repo and select the `"Actions"` section at the top navigation bar.

Select the `"Push Docker Image"` workflow from the left sidebar and click the "Run workflow" button on the right. Enter `rc2` for a tag

Wait for some minutes until GitHub actions queues the workflow and then runs it. After the workflow runs you should now see the image in the packages section of your repo.

Wait for 1-2 minutes for Argo Image updater to pick up the changes.

Verify the new image changes in the application manifests

After some time the `always-latest` application will be `out of sync`. If you look at the diff in ArgoCD UI you will see that Image Updater has correctly changed the version to `"rc2"` as this is now the newest image.

The `follow-semver` application is not affected at all.

Sync the application manually to finish the deployment.

## Release a semver version
We will release a new container tag with the name `"1.2.3"`

After we release it we expect the following

  - The `"always-latest"` application will use it right away
  - The `"follow-semver"` application will also use it as it is larger than 1.0

Let's do this now

Create a new container tag called `"1.2.3"`
Go to the Github UI of your forked repo and select the "Actions" section at the top navigation bar.

Select the `"Push Docker Image"` workflow from the left sidebar and click the `"Run workflow"` button on the right. Enter `1.2.3` for a tag

Wait for some minutes until GitHub actions queues the workflow and then runs it. After the workflow runs you should now see the image in the packages section of your repo.

Wait for 1-2 minutes for Argo Image updater to pick up the changes.

Verify the new image changes in the application manifests  

After some time both applications will be out of sync. If you look at the diff in ArgoCD UI you will see that Image Updater has correctly changed the version to `"1.2.3"` in both of them.

Sync the applications manually to finish the deployment.

## Release an out-of-range version
We will release a new container tag with the name `"2.7"`

After we release it we expect the following

  - The `"always-latest"` application will use it right away
  - The `"follow-semver"` application will do nothing as `"2.7"` is outside the `1.x` contraint

Let's do this now

Create a new container tag called `"2.7"`
Go to the Github UI of your forked repo and select the `"Actions"` section at the top navigation bar.

Select the `"Push Docker Image"` workflow from the left sidebar and click the `"Run workflow"` button on the right. Enter `2.7` for a tag

Wait for some minutes until GitHub actions queues the workflow and then runs it. After the workflow runs you should now see the image in the packages section of your repo.

Wait for 1-2 minutes for Argo Image updater to pick up the changes.

Verify the new image changes in the application manifests  

After some time the always-latest application will be out of sync. If you look at the diff in ArgoCD UI you will see that Image Updater has correctly changed the version to `"2.7"` as this is now the newest image.

Sync the application `manually` to finish the deployment.

The `follow-semver` application is not affected at all.
