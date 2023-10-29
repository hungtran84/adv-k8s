# Using Istio for fault-tolerance

> We'll cover traffic management in more detail, this is a simple example to show the power of Istio

## 3.1 Route traffic through Istio

Deploy [details-virtualservice.yaml](./details-virtualservice.yaml)

```sh
kubectl apply -f details-virtualservice.yaml
```

> Browse to http://$ISTIO_INGRESS_IP/productpage (same functionality)
```
open http://$ISTIO_INGRESS_IP/productpage
```

## 3.2 Deploy details service update which errors

A bad service update - [details-bad-release.yaml](./details-bad-release.yaml)

```
kubectl apply -f details-bad-release.yaml
```

Watch logs:

```
kubectl logs -f -l app=details -c details
```

> Browse to http://$ISTIO_INGRESS_IP/productpage - details call times out after 30 seconds
```sh
open http://$ISTIO_INGRESS_IP/productpage
```

## 3.3 Update virtual service with timeout

- [details-virtualservice-timeout.yaml](./details-virtualservice-timeout.yaml)

```
kubectl apply -f details-virtualservice-timeout.yaml
```

> Browse to http://$ISTIO_INGRESS_IP/productpage - details call times out after 5 seconds

![Alt text](image.png)

## 3.4 Update virtual service with retry

- [details-virtualservice-retry.yaml](./details-virtualservice-retry.yaml)

```sh
kubectl apply -f details-virtualservice-retry.yaml
```

> Browse to http://$ISTIO_INGRESS_IP/productpage - details call times out and then automatically retries