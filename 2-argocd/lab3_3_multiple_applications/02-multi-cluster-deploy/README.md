# Multiple clusters management

## Requirements
  - [Minikube](https://minikube.sigs.k8s.io/docs/start/)
  - Docker Desktop
  - [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
  - A GCP project or a Kubernetes Cluster (for multi-cluster deployments)
  - You need to have a GitHub account for this exercise. The example application is at https://github.com/hungtran84/argocd-example-app.git.
  - Fork this repository in your own account.

## Objectives
In this track, you'll learn:

  - How Argo CD can connect to external clusters
  - How to use a local kubeconfig file to add an external cluster to Argo CD

## Setup the minikube cluster
We’ll be using minikube to create our cluster and install Argo CD.

```sh
chmod +x minikube.sh
./minikube.sh
```
Login to Argo CD UI using the username: admin and password

## Add an external cluster to ArgoCD
We’ll have to setup RBAC and access credentials for ArgoCD to connect to the cluster that we just created. The CLI makes this easy. Run the following command:

```sh
argocd cluster add gke_[PROJECT_ID]_[REGION]_[CLUSTER_NAME] # Your context name
```

Output like below
```sh
argocd cluster add gke_sunlit-wall-399414_europe-west2_gke-terraform-project --name gke

WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `gke_sunlit-wall-399414_europe-west2_gke-terraform-project` with full cluster level privileges. Do you want to continue [y/N]? y
INFO[0004] ServiceAccount "argocd-manager" already exists in namespace "kube-system" 
INFO[0004] ClusterRole "argocd-manager-role" updated    
INFO[0005] ClusterRoleBinding "argocd-manager-role-binding" updated 
Cluster 'https://34.89.33.164' added
```

## Example application

Our example application can be found at `https://github.com/hungtran84/argocd-example-app.git`

Make sure to fork it to your own account and note down the URL. It should be something like: `https://github.com/<your user>/argocd-example-app/`

It is a very simple Kubernetes application that we want to deploy in a different cluster that will be managed by our main Argo CD cluster.

## Deploying applications to an external cluster
Now that the external cluster is added let's deploy an application to it.

Create an Argo CD application from the UI or the CLI with the following details

```yaml
application name : external-app
project: default
SYNC POLICY: auto
repository URL: https://github.com/<your user>/argocd-example-app/
path: ./simple-app
Cluster: https://<your external cluster IP>
Namespace: default
```

If you have trouble creating Argo CD applications by yourself, be sure to look the first part of the certifications "GitOps fundamentals".

The application is now deployed on the second cluster.

Run in the terminal of "GKE Cluster" the following command:
```sh
kubectl get all
```

This will show you all the Kubernetes resources running on the second cluster.

## Deploying applications to the internal cluster
It is important to mention that you can still deploy applications to the cluster that is running Argo CD itself like you normally do.

Try this now:

Create an Argo CD application from the UI or the CLI with the following details
```yaml
application name : internal-app
project: default
SYNC POLICY: auto
repository URL: https://github.com/<your user>/argocd-example-app/
path: ./simple-app
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed - Minikube cluster)
Namespace: default
```

The application will deploy and you will see it along with the external one in the Argo CD UI.

This means that essentially you can have 3 possible types of Argo CD instances:
  - Argo CD instance that deploys applications on the same cluster it is running on
  - Argo CD instance that deploys applications only on externally managed clusters
  - Argo CD instance that does both internal and external app deployment

The exact setup depends on your organization needs.

## Deploy a Argo Workflows cluster add-on via ApplicationSet controller

We can define `ApplicationSet` resource to pull the Argo Workflow kubernetes artifacts

```sh
cat > application-set.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: argo-workflows
  namespace: argocd
spec:
  generators:
  - clusters: {} 
  template: 
    metadata:
      name: "{{name}}-argo-workflows"
    spec:
      project: "default"
      source:
        repoURL: https://github.com/<your user>/argocd-example-app/
        targetRevision: HEAD
        path: argo-workflow
      destination:
        server: '{{server}}'
        namespace: argo
      syncPolicy:
        syncOptions:    
        - CreateNamespace=true
        automated:
          prune: true
          selfHeal: true
EOF
```
Create the applications as below command
```sh
kubectl config use-context minikube 
kubectl create -n argocd -f application-set.yaml
```
Now, Argo CD’s `ApplicationSetcontroller` will create an Application resources to deploy the argo workflow application in both cluster `minikube` and `gke` which can be verified from the ArgoCD’s web UI.