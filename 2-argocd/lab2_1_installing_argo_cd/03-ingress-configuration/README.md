# GKE Ingress Configuration
To configure ingress with Google Cloud Load Balancer for ArgoCD we need to perform the below steps  

## Disable internal TLS
To disable internal TLS, we need to pass the --insecure flag to the argocd-server command, this will avoid an internal redirection loop from HTTP to HTTPS. For this, we need to edit the deployment named “argocd-server” and make the following changes  

The container command should change from:
```yaml
containers:
- command:
  - argocd-server
```

To:
```yaml
containers:
- command:
  - argocd-server
  - --insecure
```

Or

We can set server.insecure: “true” in the “argocd-cmd-params-cm” ConfigMap as shown below  

```
data:
    server.insecure: "true"
```

## Create an externally accessible service
We need to create an externally accessible service which will be a ClusterIP service type and have annotation as (Network Endpoint Group) NEG that will allow your load balancer to send traffic directly to your pods without the kube-proxy being used.

```
kubectl apply -f server-external.yaml
```

## Create BackendConfig
Create Backend Config which is being referenced in external service to perform health checks  
```
kubectl apply -f backend-config.yaml
```

## Create FrontendConfig
Now we will create Frontend Config that will redirect HTTP to HTTPS  
```
kubectl apply -f frontend-config.yaml
```
## Create Global Static IP
Create a static global IP which will be mapped to DNS
```
gcloud compute addresses create argocd-ingress-ip  --global --ip-version IPV4
```
## Set static IP to host file
Check the created static IP in GCP console
Search -> IP addresses -> argocd-ingress-ip

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

## Create ManagedCertificate
Here we will be creating Managed SSL certificate which will be used in the Load balancer  
```
kubectl apply -f cert.yaml
```

## Create Ingress
Finally, we will be creating an Ingress object which is having reference to our frontend config, service, and managed certificate  
```
kubectl apply -f ingress.yaml
```

# Login ArgoCD
Now you can login ArgoCD via https://argocd.yourcorp.com