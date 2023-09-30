# Install Argocd CLI
```
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.1.5/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

# Test that the CLI works by typing
```
argocd help
```

# Login with the CLI
```
argocd login localhost:30443 --insecure
```

# Run some example commands
```
argocd version
argocd app list
```