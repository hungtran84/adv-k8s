# 1. Use the exmpale file to create a argocd project
```
kubectl apply -f app-project.yaml 
```

# 2. Use the exmpale file to create a argocd application
```
kubectl apply -f application.yaml 
```

# 3. Remove the application
```
kubectl delete -f application.yaml
```