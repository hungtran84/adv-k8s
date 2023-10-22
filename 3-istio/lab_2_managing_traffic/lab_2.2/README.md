# Lab 2.2 - Blue/Green Deployment

Launch a new version of the homepage, and switch the domain between live and test versions.

## 1. Setup

Deploy Istio & bookinfo

## 2. Deploy v2

Using existing gateway:

```sh
kubectl describe gateway bookinfo-gateway
```

Deploy [v2 product page with test domain](productpage-v2.yaml):

```sh
kubectl apply -f productpage-v2.yaml
```

```sh
$ kubectl apply -f productpage-v2.yaml
deployment.apps/productpage-v2 created
destinationrule.networking.istio.io/productpage created
virtualservice.networking.istio.io/bookinfo created
virtualservice.networking.istio.io/bookinfo-test created
```

Check deployment:

```sh
kubectl get pods -l app=productpage
```

```sh
$ kubectl get pods -l app=productpage
NAME                              READY   STATUS    RESTARTS   AGE
productpage-v1-66756cddfd-4r4vn   2/2     Running   0          6h26m
productpage-v2-856cdf87c7-hhfn4   2/2     Running   0          108s
```

```sh
kubectl get vs
```

```sh
$ kubectl get vs
NAME            GATEWAYS               HOSTS                     AGE
bookinfo        ["bookinfo-gateway"]   ["bookinfo.local"]        2m40s
bookinfo-test   ["bookinfo-gateway"]   ["test.bookinfo.local"]   2m40s
```

Add `bookinfo.local` domains to hosts file:

```sh
# Windows
cat C:\Windows\System32\drivers\etc\hosts

# on Linux or Mac add to `/etc/hosts`
sudo vim /etc/hosts
```

```sh
$ tail /etc/hosts
# Istio test
127.0.0.1 bookinfo.local
127.0.0.1 test.bookinfo.local
```

> Browse to live v1 set at http://bookinfo.local/productpage

> Browse to test v2 site at http://test.bookinfo.local/productpage

## 3. Blue/green deployment - flip

Deploy [test to live switch](./productpage-test-to-live.yaml)

```
kubectl apply -f productpage-test-to-live.yaml
```

Check live deployment:

```
kubectl describe vs bookinfo
```

> Live is now v2 at http://bookinfo.local/productpage

Check test deployment:

```
kubectl describe vs bookinfo-test
```

> Test is now v1 at http://test.bookinfo.local/productpage

## 4. Blue/green deployment - flip back

Deploy [live to test switch](./productpage-live-to-test.yaml)

```sh
kubectl apply -f productpage-live-to-test.yaml
```

> Live is back to v1 http://bookinfo.local/productpage
> Test is back to v2 http://test.bookinfo.local/productpage
