# Google Kubernetes Engine

Follow these instructions to prepare a GKE cluster for Istio.

0. Clean up the existing cluster

```sh
gcloud container clusters delete adv-k8s-cluster --location asia-southeast1-a -q
```

1. Create a new cluster.

```sh
export PROJECT_ID=`gcloud config get-value project` && \
export M_TYPE=n1-standard-2 && \
export ZONE=us-west2-a && \
export CLUSTER_NAME=${PROJECT_ID}-${RANDOM} && \
gcloud services enable container.googleapis.com && \
gcloud container clusters create $CLUSTER_NAME \
--cluster-version latest \
--machine-type=$M_TYPE \
--disk-size=80GB \
--num-nodes 3 \
--zone $ZONE \
--project $PROJECT_ID
```

2. Retrieve your credentials for `kubectl`.

```sh
gcloud container clusters get-credentials $CLUSTER_NAME \
    --zone $ZONE \
    --project $PROJECT_ID
```

3. Grant cluster administrator (`admin`) permissions to the current user. To create the necessary RBAC rules for Istio, the current user requires admin permissions.

```sh
kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)
```