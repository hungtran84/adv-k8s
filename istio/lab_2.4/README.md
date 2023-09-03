# Lab 2.4 Circuit Breaker

Add outlier detection to a load-balanced servcie so unhealthy endpoints are removed.

## 1. Setup

Follow the steps from [Lab 2.1](../lab_2.1/README.md).

Deploy gateway

```sh
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/networking/bookinfo-gateway.yaml
```

Clean up old resources

```sh
kubectl delete -f ../lab_2.2/
```


## 2. Deploy details v2 service

Deploy [service update with 4 replicas](details-v2.yaml):

```sh
kubectl apply -f details-v2.yaml
```

Check deployment:

```
kubectl describe service details

kubectl describe vs details

kubectl describe dr details
```

> Browse to http://localhost/productpage & refresh lots. Around 50% of details call fail.

Check logs:

```
kubectl logs -l app=details,version=v2 -c details
```

## 4.2 Apply circuit breaker

Deploy [updated rules with outlier detection](details-circuit-breaker.yaml):

```
kubectl apply -f details-circuit-breaker.yaml
```

Check deployment:

```
kubectl describe dr details
```

> Browse to http://localhost/productpage & refresh lots. As pods return errors they get excluded - after a while there are no errors, requests only go to healthy pods.
