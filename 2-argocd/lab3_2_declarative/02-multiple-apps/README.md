# Use App of Apps
We can delete the application like any other Kubernetes resource

```
kubectl delete -f my-application.yml
```

After a while the application should disappear from the ArgoCD UI.

Remember however that the whole point of GitOps is to avoid manual `kubectl` commands. We want to store this application manifest in Git. And if we store it in Git, we can handle it like another GitOps application!

ArgoCD can manage any kind of Kubernetes resources and this includes its own applications (inception).

So we can commit multiple applications in Git and pass them to ArgoCD like any other kind of manifest. This means that we can handle multiple applications as a single one.

We already have such example at https://github.com/hungtran84/argocd-example-app/tree/master/declarative/multiple-apps.

Deploy the root app from manifest
```sh
kubectl apply -f 3-apps.yml
```

Notice that the namespace value is the namespace where the parent Application is deployed and not the namespace where the individual applications are deployed. ArgoCD applications must be deployed in the same namespace as ArgoCD itself.


ArgoCD will deploy the parent application and its 3 children.

Verify 3 app resources with
```
kubectl get all -n demo1
kubectl get all -n demo2
kubectl get all -n demo3
```

