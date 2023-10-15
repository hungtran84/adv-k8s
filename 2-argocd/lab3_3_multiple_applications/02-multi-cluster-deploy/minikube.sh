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

INGRESS_HOST=$(minikube ip)
export INGRESS_HOST

###################
# Install Argo CD #
###################

helm repo add argo https://argoproj.github.io/argo-helm

helm upgrade --install argocd argo/argo-cd \
    --namespace argocd --create-namespace \
    --set server.ingress.hosts="{argocd.lab.local}" \
    --values argo/argocd-values.yaml --wait

PASS=$(kubectl --namespace argocd \
    get secret argocd-initial-admin-secret \
    --output jsonpath="{.data.password}" | base64 -d)

export PASS

argocd login --insecure --username admin --password $PASS \
    --grpc-web argocd.lab.local

echo $PASS

open http://argocd.lab.local

#######################
# Destroy The Cluster #
#######################

# minikube delete