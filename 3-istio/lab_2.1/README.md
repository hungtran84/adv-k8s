# Lab 2.1 - Dark Launch

Launch new version of the reviews service which only the test user can see.

## 1. Setup

Set the default namespace to `bookinfo`

```sh
kubectl config set-context --current --namespace=bookinfo
kubectl config view --minify | grep namespace:
```

Deploy Istio & bookinfo apps v1 to `bookinfo` namespace

```sh
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account in (reviews,details,ratings,productpage)'
```

```sh
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account in (reviews,details,ratings,productpage)'
serviceaccount/bookinfo-details created
serviceaccount/bookinfo-ratings created
serviceaccount/bookinfo-reviews created
serviceaccount/bookinfo-productpage created
```

```sh
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml -l version=v1
```

```sh
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml -l version=v1
deployment.apps/details-v1 created
deployment.apps/ratings-v1 created
deployment.apps/reviews-v1 created
deployment.apps/productpage-v1 created
```

```sh
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml -l 'service in (reviews,details,ratings,productpage)'
```

```sh
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml -l 'service in (reviews,details,ratings,productpage)'
service/details created
service/ratings created
service/reviews created
service/productpage created
```

## 2. Deploy v2

Deploy [v2 reviews service](./reviews-v2.yaml):

```sh
kubectl apply -f reviews-v2.yaml
```

Check deployment:

```
kubectl get pods -l app=reviews

kubectl describe svc reviews
```

> Browse to http://localhost/productpage and refresh, requests load-balanced between v1 and v2

## 3. Switch to dark launch

Deploy [test user routing rules](./reviews-v2-tester.yaml):

```sh
kubectl apply -f reviews-v2-tester.yaml

kubectl describe vs reviews
```

> Browse to http://localhost/productpage - all users (including unauthenticated one) should see v1

Test sign-in with `tester` user (no password needed for now), reload the website to see v2

## 4. Test with network delay

Deploy [delay test rules](./reviews-v2-tester-delay.yaml):

```sh
kubectl apply -f reviews-v2-tester-delay.yaml
```

> Browse to http://localhost/productpage - `tester` gets delayed response, all others OK

Change `fixDelay` to `7s`, sign-in with `tester` and reload the productpage. The Reviews section displays an error message:

> Sorry, product reviews are currently unavailable for this book.

🏋️‍♂️ **Challenge**

Troubleshoot/investigate to understand what happened

## 5. Test with service fault

Deploy [503 error rules](./reviews-v2-tester-503.yaml)

```sh
kubectl apply -f reviews-v2-tester-503.yaml
```

> Browse to http://localhost/productpage -  `tester` gets failures.

## 6. Clean up

```sh
kubectl delete -f reviews-v2-tester-503.yaml
kubectl apply -f reviews-v2.yaml
```
