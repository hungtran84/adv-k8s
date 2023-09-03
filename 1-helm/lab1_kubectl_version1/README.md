# Deploy `GuestBook` v1

- Start Minikube tunnel

```
minikube tunnel &
```

- Deploy `frontend` application

```
kubectl apply -f frontend.yaml
```

- Expose the application

```
kubectl apply -f frontend-service.yaml
```

- Expose with the ingress

```
kubectl apply -f ingress.yaml
```

- Access the application UI

![Alt text](image.png)

- Leave your message 

![Alt text](image-1.png)

- It works !

![Alt text](image-2.png)

