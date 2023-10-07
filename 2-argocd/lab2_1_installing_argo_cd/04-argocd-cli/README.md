# Install Argocd CLI
```sh
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.1.5/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

# Test that the CLI works by typing
```sh
argocd help
```

# Login with the CLI
```sh
kubectl port-forward services/argocd-server 8888:80 -n argocd &
argocd login localhost:8888 --insecure --plaintext
```

# Run some example commands
```sh
argocd version
argocd app list
```