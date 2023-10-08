# ArgoCD declarative format
Since our ArgoCD application is now a Kubernetes resource we can handle it like any other kubernetes resource.

We have checked out for you locally the file my-application.yml Apply it with

```
kubectl apply -f my-application.yml
```

We have also installed Argo CD for you and you see it in the UI tab.

You should now see the application already in the ArgoCD UI.