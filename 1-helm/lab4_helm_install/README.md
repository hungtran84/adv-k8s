# Installing helm
 
## Helm installation

### From Script
Helm now has an installer script that will automatically grab the latest version of Helm and install it locally.

You can fetch that script, and then execute it locally. It's well documented so that you can read through it and understand what it is doing before you run it.

```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

### From Homebrew (macOS)
```
brew install helm
```

### From Chocolatey (Windows)
```
choco install kubernetes-helm
```

### From Apt (Debian/Ubuntu)
```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

### From dnf/yum
```
sudo dnf install helm
```

- Check `helm` version
```
helm version --short
```

- Add `helm` repo
```
helm repo add "stable" "https://charts.helm.sh/stable"
```
## MySql installation with helm legacy

- Install mysql chart (for testing purpose only since this chart is deprecated)
```
helm install mysql-test stable/mysql
```

- Get the mysql root password and store to a variable

```
MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace default mysql-test -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)
```

- Run an Ubuntu pod that you can use as a client

```
$kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il

root@ubuntu:/# apt-get update && apt-get install mysql-client -y
root@ubuntu:/# mysql -h mysql-test -p
```

## MySql installation with helm OCI
```
helm install mysql-test oci://ghcr.io/hungtran84/mysql
```

- Get the administrator credentials

```
MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace default mysql-test -o jsonpath="{.data.mysql-root-password}" | base64 -d)
```
- Run an Ubuntu pod that you can use as a client

```
kubectl run mysql-test-client --rm --tty -i --restart='Never' --image  docker.io/bitnami/mysql:8.0.34-debian-11-r31 --namespace default --env MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD --command -- bash
```

- Connect to primary service (read/write)

```
$ mysql -h mysql-test.default.svc.cluster.local -uroot -p"$MYSQL_ROOT_PASSWORD"

Your MySQL connection id is 28
Server version: 8.0.34 Source distribution

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```
## Helm cleaning

- Display the helm releases

```
helm ls
```

- Examine the current resources

```
kubectl get all | grep mysql-test
kubectl get secret | grep mysql-test
```

- Cleanup helm release
```
helm uninstall mysql-test
```
