# Secret Management
Our example application can be found at `https://github.com/hungtran84/argocd-example-app.git/tree/master/secret-app`

Make sure to fork it to your own account and note down the URL. It should be something like:

`https://github.com/<your user>/argocd-example-app`

Take a look at the Kubernetes manifests in `secret-app/manifests/` to understand what we will deploy.

It is a very simple application with one deployment and one service that also needs two secrets files (for db connection and paypal certificate) that are passed to the application as files under `/secrets/`.

The two secrets are stored in the files `db-creds-encrypted.yaml` and `paypal-cert-encrypted.yaml` These files are empty in the Git repository because we want to encrypt them first.

## Install the Sealed Secrets controller
We have placed the raw/unencrypted secrets in your work directory that are needed by the application. You can look at the files in the Editor tab.

These secrets are plain Kubernetes secrets and are not encrypted in any way. Let's install the Bitnami Sealed secrets controller to encrypt our secrets.

Login in the UI tab.

The UI starts empty because nothing is deployed on our cluster. Click the "New app" button on the top left and fill the following details:

```yaml
application name : controller
project: default
SYNC POLICY: automatic
repository URL: https://github.com/hungtran84/argocd-example-app.git
path: ./bitnami-sealed-controller
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: kube-system
Leave all the other values empty or with default selections. Finally click the Create button. The controller will be installed on the cluster.
```

>Notice that are using a specific namespace for the controller and not the default one. It is imperative to enter kube-system otherwise the secrets controller will not work.

You can see that GitOps is not only useful for your own applications but also for other supporting applications as well.  

## Use Kubeseal to encrypt secrets
The Sealed Secrets controller is running now on the cluster and it is ready to decrypt secrets.
kube
We now need to encrypt our secrets and commit them to git. Encryption happens with the kubeseal executable. It needs to be installed in the same way as kubectl. It re-uses the cluster authentication already used by kubectl.

## Install Kubeseal
#### Homebrew
The `kubeseal`  client is also available on `homebrew`:
```sh
brew install kubeseal
```

#### Linux
The `kubeseal` client can be installed on Linux, using the below commands:

```sh
KUBESEAL_VERSION='0.23.0'
wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION:?}/kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz"
tar -xvzf kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

If you have `curl` and `jq` installed on your machine, you can get the version dynamically this way. This can be useful for environments used in automation and such.
```sh
# Fetch the latest sealed-secrets version using GitHub API
KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/tags | jq -r '.[0].name' | cut -c 2-)

# Check if the version was fetched successfully
if [ -z "$KUBESEAL_VERSION" ]; then
    echo "Failed to fetch the latest KUBESEAL_VERSION"
    exit 1
fi

wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
tar -xvzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```
## Encrypt your plain
You can use it right away to encrypt your plain Kubernetes secrets and convert them to encrypted secrets

Run the following

```sh
kubeseal < unsealed_secrets/db-creds.yml > sealed_secrets/db-creds-encrypted.yaml -o yaml
kubeseal < unsealed_secrets/paypal-cert.yml > sealed_secrets/paypal-cert-encrypted.yaml -o yaml
```

Now you have encrypted secrets. Open the files in the `"Editor"` tab and copy the contents in your clipboard.

Then go the Github UI in another browser tab and commit/push their contents in your own fork of the application, filling the empty files at 

`argocd-example-app/secret-app/manifests/db-creds-encrypted.yaml `

and

`
argocd-example-app/secret-app/manifests/paypal-cert-encrypted.yaml
` 

## Deploy secrets
Now that all our secrets are in Git in an encrypted form we can deploy our application as normal.

Login in the Argo CD UI.

Click the `"New app"` button on the top left and fill the following details:

```yaml
application name : demo
project: default
SYNC POLICY: automatic
repository URL: https://github.com/<your user>/argocd-example-app
path: ./secret-app/manifests
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: default

```
Leave all the other values empty or with default selections. 

Finally click the Create button. The application entry will appear in the main dashboard. Click on it.

The application should now be deployed. Once it is healthy you can see it running in the `"Deployed app"` tab. 

Just for illustration purposes, the application is showing the secrets it can access. This way you can verify that the sealed secrets controller is working as expected, decrypting secrets on the fly.