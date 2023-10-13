# Environment Promotion
## Introduction
Our example application can be found at https://github.com/hungtran84/argocd-example-app/tree/master/environment-promotion

Make sure to fork it to your own account and note down the URL. It should be something like: `https://github.com/<your user>/argocd-example-app/`

Take a look at the Kubernetes manifests to understand what we will deploy. It is a very simple application with one deployment and one service organized in a set of Kustomize templates.

## First deployment
The first deployment  

You can login in the UI tab.

The UI starts empty because nothing is deployed on our cluster. As a first step we will deploy the same application to 3 environments. 

Normally it is a good practice to have your production workloads in a separate cluster, but just for this exercise we will use a single cluster (the same one that ArgoCD is installed) and instead imitate environments with 3 namespaces

Create 3 Argo CD applications one for each folder at `https://github.com/<your user>/argocd-example-app/`:
  ```yaml
      ./environment-promotion/envs/prod
      ./environment-promotion/envs/staging
      ./environment-promotion/envs/qa
  ```

These should be installed in the `prod`, `staging`, `qa` namespaces respectively. These namespaces do not exist in the cluster and you need to create them first either manually or via the `create namespace` option in Argo CD.

You can use any valid method to create the apps, such as the ArgoCD CLI or the UI or even your own custom Application resource. Be sure to enable `auto-sync` and `self-heal` for all the applications or alternatively you will have to sync manually everytime we do a change.

## Inspecting the apps
### Organization of the manifests

If you look at the manifests located in each folder each application is defined by the following files

  - `version.yml`: defines the container image
  - `settings.yml`: defines application level settings for the application (environment variables)
  - `replicas.yml`: defines the number of replicas
  - `services.yml`: defines the port for each application

All these files are managed via Kustomize and are defined according to the promotion scenario of your organization. In our example we will mostly deal with the first two files. You can do a different split depending on your needs. 

For example in our case we can move settings between different environments by copying the settings.yml file while still having different replicas per environment.

We have also included 2 Kustomize modules. The [prod](https://github.com/hungtran84/argocd-example-app/tree/master/environment-promotion/variants/prod) one for production and the [non-prod](https://github.com/hungtran84/argocd-example-app/tree/master/environment-promotion/variants/non-prod) one that is used for both qa and staging environments.

### Viewing the applications

We have added 3 separate tabs at the top so that you can see how each application instance looks like. The version of each application as well as the settings are completely different between the 3 environments. This is the initial state and we will now see different promotion scenarios

## How promotion works

Promotion of a release works by simply copying files between the overlay folders (and then committing the changes so that Argo CD syncs each environment).

You can copy a single file or multiple files depending on what you want to promote from one environment to another.

For example if you want to make sure that 2 environments have the same number of replicas you can copy the `replicas.yml` file from one folder to another.

### Promoting the container image from Staging to Production
In the most basic scenario you want to promote the container image from one environment to the next. The container tag is defined in the manifest called `version.yml.`

Promote the current application version from the Staging environment to Production by copying the file `./environment-promotion/envs/staging/version.yml` to `./environment-promotion/envs/prod/version.yml` in your own git fork.

There are multiple ways to do that

  - Clone the repo locally and then just use `cp` to copy the file or a text editor to change the text
  - Use the Github UI and change the `production/version.yml` file with the same version as found in the Staging file
  - Commit/push your changes to trigger an Argo CD sync

The production environments should now have the same version as the staging environment.

You can use the application tabs to verify that or even the ArgoCD UI/CLI once the deployment has finished. Click the small refresh icon at the top right of the `"Production App"` tab to see the change.

### Promoting the application using CI
Automating promotions.

Promoting by copying files can be automated by your CI system or any other high level system. In this example we will use Github actions as it is already part of Github but you can do the same thing with any other CI system

Take a look at the [promote workflow](https://github.com/hungtran84/argocd-example-app/blob/master/.github/workflows/promote.yml).

This is a GitHub workflow that can be triggered on demand. It takes as arguments

  - The source environment
  - The target environment
  - Whether the application version will be promoted
  - Whether the settings of the application will be promoted (explained in the next section)

Then it runs and does the following

  - Checks out the manifests from the Git repository
  - Copies the appropriate files from one folder to the other
  - Commits and pushes the changes back

### Enabling Github actions workflows in your repo
Instead of manually editing files lets run the workflow this time. Go to the Github UI of your forked repo and select the `"Actions"` section at the top navigation bar.

Click the big green button that says `"I understand my workflows, go ahead and enable them"`

Also make sure to allow the workflows to commit back to your repo by visiting `https://github.com/<your_github_user>/argocd-example-app/settings/actions` and enabling `read-write` access at the bottom of the page.

## Promoting the container image from QA to staging
Select the `"Promote application"` workflow from the left sidebar and click the `"Run workflow"` button on the right. Select the following options:

After the workflow runs you should now see that version `3.0` of the application was moved from `QA` to `staging`. You can use the application tabs to verify that or even the ArgoCD UI/CLI once the deployment has finished. Click the small refresh icon at the top right of the `"Staging App"` tab to see the change.