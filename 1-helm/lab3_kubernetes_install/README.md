# Lab setup

## Minikube
 
### Docker installation check
docker version

### Minikube installation

https://minikube.sigs.k8s.io/docs/start/

```shell
# For MacOS M1
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64
sudo install minikube-darwin-arm64 /usr/local/bin/minikube
minikube version
minikube start
```

### Minikube configuration
```
minikube addons enable ingress
minikube ip
sudo vi /etc/hosts
```

## GKE

### Register a GCP Free-Trail account
- Go to cloud.google.com
  
![Alt text](image.png)

- Enter your gmail or GSuite email

![Alt text](image-1.png)

- Accept `Terms of Service`

![Alt text](image-2.png)

- Fill the payment information

![Alt text](image-3.png)

- Successfully registered Free-tier account with $300

![Alt text](image-4.png)

- The first GCP project has automatically created for you with the name `My First Project`

![Alt text](image-5.png)

> [!IMPORTANT]  
> DO NOT hit `ACTIVATE FULL ACCOUNT` button above to avoid any additional fee!
### Create GKE cluster

```

```


