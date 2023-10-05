# Provision GKE Cluster with Terraform Using Module
## Prerequisite:

Before you can provision a GKE cluster using Terraform, you need to ensure that you have the following prerequisites in place:

- Google Cloud Platform (GCP) Account: GCP account with the necessary permissions to create and manage resources.
- Google Cloud SDK (gcloud) : which provides the command-line tools for interacting with GCP services.
- Enable Google Kubernetes Engine (GKE) API: Enable the GKE API for your project. You can enable it either through the Google Cloud Console or by running the following command with the gcloud CLI.
- Authentication and Credentials: Configure authentication for Terraform to access your GCP account. You can use either Application Default Credentials (ADC) or a Service Account key file
- Install local tools: 
  - Terraform https://terraform.io/downloads.html 
  - kubectl https://kubernetes.io/docs/tasks/tools
  - gcloud https://cloud.google.com/sdk/docs/install

## Set up a project on your Google Cloud account
To create a new project in Google Cloud using the Console, you can follow the revised steps below:

Open the Google Cloud Console in your web browser.
Navigate to the “Manage Resources” page and Create a new project. Enter project details and finally review and create the project.

## Enable required API
Enabling the APIs allows Terraform to interact with the necessary Google Cloud services and resources.

To enable the required APIs for your project, you need to select and enable two APIs: the Compute Engine Api and Kubernetes Engine Api.If you need assistance locating these APIs in the Cloud Console API Library, you can use the search field and search for each API separately.

```
$ gcloud init
$ gcloud services enable container.googleapis.com
$ gcloud services enable compute.googleapis.com
```

## Create a Service Account:
It is recommended to use separate service accounts for different services. In this guide, we will create a dedicated service account for Terraform to ensure proper isolation and control over its permissions.

Go to the Service accounts page: [serviceaccounts](https://console.cloud.google.com/projectselector2/iam-admin/serviceaccounts?supportedpurview=project) in the Google Cloud Console.
Click the Create service account button, Enter a name for the service account.
Select a role for the service account and Click the Create button.
The service account will be created and a JSON key file will be downloaded to your computer. This file contains the service account credentials

## Initialize the gcloud SDK:
```
gcloud auth list
gcloud auth application-default login
gcloud config set account <ACCOUNT>
gcloud config set project <PROJECT_ID>
```

## Provision GKE Cluster with Terraform
Update the values in **terraform.tfvars** and run following commands:
```
terraform init
terraform plan
terraform apply --auto-approve
```

## Get kubernetes credential
```
gcloud components install gke-gcloud-auth-plugin
gcloud container clusters get-credentials <CLUSTER_NAME> --region <REGION> --project <PROJECT_ID>
```

## Set static IP to host file
Check the created static IP
```
kubectl get ingress  -n argocd 
```

To update the ip address in host file
```
sudo vim /etc/hosts
```
```
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost
13.13.13.13     argocd.yourcorp.com
# End of section
```

# Get admin password

Get the password of the Argo CD application, for ‘admin’ username, by executing the below command.
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

# Login ArgoCD
Now you can login ArgoCD via http://argocd.yourcorp.com