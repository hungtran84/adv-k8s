# Deploying an Istio-managed app

> We're using a modified version of the [Istio BookInfo sample app](https://github.com/istio/istio/tree/master/samples/bookinfo)

## 2.1 Deploy BookInfo

Deploy the app ([bookinfo-v1.yaml](./bookinfo-v1.yaml)):

```
kubectl apply -f bookinfo-v1.yaml
```

And the gateway ([bookinfo-gateway.yaml](./bookinfo-gateway.yaml)):

```
kubectl apply -f bookinfo-gateway.yaml
```

## 2.2 Verify the install

Check pods:

```
kubectl get pods
```

Check gateway:

```
kubectl get svc istio-ingressgateway -n istio-system

ISTIO_INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

export $ISTIO_INGRESS_IP
```

Open Productpage app
```sh
open http://$ISTIO_INGRESS_IP/productpage
```

