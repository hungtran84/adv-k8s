# Lab 2.3 - Canary Deployment

## 1. Setup

Follow the steps from [Lab 2.1](../lab_2.1/README.md).

Deploy `productpage` v2 deployment

```sh
kubectl apply -f productpage-v2-deployment.yaml
```

## 2. Canary with 30% traffic to v2

Deploy [canary rules with 70/30 split](productpage-canary-70-30.yaml)

```sh
kubectl apply -f productpage-canary-70-30.yaml
```

Check deployment:

```sh
kubectl describe vs bookinfo-test

kubectl describe vs bookinfo
```

> Browse to http://bookinfo.local/productpage & refresh, mostly v1 responses with some v2

## 3.2 Canary rollout

Shift traffic to v2:

- [55/45 split](productpage-canary-55-45.yaml)
- [25/75 split](productpage-canary-25-75.yaml)
- [0/100 split](productpage-canary-0-100.yaml)

## 3.3 Canary with sticky session

Deploy [canary split with with cookie](productpage-canary-with-cookie.yaml):

```
kubectl apply -f productpage-canary-with-cookie.yaml
```

> Browse to http://bookinfo.local/productpage & refresh - once you hit v2 that puts a cookie in your browser, and you'll always get v2

Check by disabling cookies:

- Chrome
  - Access `chrome://settings/cookies`
  - Customized behaviors
  - Sites that can never use cookies
  - Add `bookinfo.local`

> Browse to http://bookinfo.local/productpage & refresh - back to 70/30 split
