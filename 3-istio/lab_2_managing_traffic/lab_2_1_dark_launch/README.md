# Dark Launch

Launch new version of the reviews service which only the test user can see.

## 1.0 Pre-reqs

Deploy Istio gateway & bookinfo:

```
kubectl apply -f ../setup/
```

## 1.1 Deploy v2

Deploy [v2 reviews service](./reviews-v2.yaml):

```
kubectl apply -f reviews-v2.yaml
```

Check deployment:

```
kubectl get pods -l app=reviews

kubectl describe svc reviews
```

> Browse to http://$ISTIO_INGRESS_IP/productpage and refresh, requests load-balanced between v1 and v2

## 1.2 Switch to dark launch

Deploy [test user routing rules](./reviews-v2-tester.yaml):

```sh
kubectl apply -f reviews-v2-tester.yaml

kubectl describe vs reviews
```

> Browse to http://$ISTIO_INGRESS_IP/productpage - all users see v1 except `tester` who sees v2

![Alt text](image-1.png)

![Alt text](image.png)

## 1.3 Test with network delay

Deploy [delay test rules](./reviews-v2-tester-delay.yaml):

```sh
kubectl apply -f reviews-v2-tester-delay.yaml
```

> Browse to http://$ISTIO_INGRESS_IP/productpage - `tester` gets delayed response, all others OK

## 1.4 Test with service fault

Deploy [503 error rules](./reviews-v2-tester-503.yaml)

```sh
kubectl apply -f reviews-v2-tester-503.yaml
```

> Browse to http://$ISTIO_INGRESS_IP/productpage -  `tester` gets 50% failures, all others OK