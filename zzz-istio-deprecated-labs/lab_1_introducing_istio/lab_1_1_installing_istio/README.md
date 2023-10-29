# Istalling Istio

> Adapted from the [Istio Quick Start](https://istio.io/docs/setup/kubernetes/quick-start/)

## 1.1 Deploy Istio
- With istioctl
- With Helm

## 1.2 Verify Istio

Running objects:

```
kubectl get all -n istio-system
```

> All components have memory requests

## 1.3 Configure auto proxy injection

Configure default namespance:

```sh
kubectl label namespace default istio-injection=enabled
```

Check label:

```sh
kubectl describe namespace default
```


