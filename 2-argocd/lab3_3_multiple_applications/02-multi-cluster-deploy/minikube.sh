####################
# Create a Cluster #
####################

minikube start

#############################
# Deploy Ingress Controller #
#############################

minikube addons enable ingress

kubectl --namespace ingress-nginx wait \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=120s

export INGRESS_HOST=$(minikube ip)

###################
# Install Argo CD #
###################

helm repo add argo https://argoproj.github.io/argo-helm

helm upgrade --install argocd argo/argo-cd \
    --namespace argocd --create-namespace \
    --set server.ingress.hosts="{argocd.$INGRESS_HOST.nip.io}" \
    --values argo/argocd-values.yaml --wait

export PASS=$(kubectl --namespace argocd \
    get secret argocd-initial-admin-secret \
    --output jsonpath="{.data.password}" | base64 -d)

argocd login --insecure --username admin --password $PASS \
    --grpc-web argocd.$INGRESS_HOST.nip.io

echo $PASS


#######################
# Destroy The Cluster #
#######################

minikube delete