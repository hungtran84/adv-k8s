# helloworld with variants

## Create Overlays

Create a `staging` and `production` [overlay]:

 * `staging` enables a risky feature not enabled in `production`.
 * `production` has a higher replica count.
 * Web server greetings from these cluster
   [variants] will differ from each other.


```
DEMO_HOME=lab1_2_helloworld
BASE=$DEMO_HOME/base
OVERLAYS=$DEMO_HOME/overlays
mkdir -p $OVERLAYS/staging
mkdir -p $OVERLAYS/production
```

#### Staging Kustomization

In the `staging` directory, make a kustomization
defining a new name prefix, and some different labels.


```sh
cat <<'EOF' >$OVERLAYS/staging/kustomization.yaml
namePrefix: staging-
commonLabels:
  variant: staging
  org: acmeCorporation
commonAnnotations:
  note: Hello, I am staging!
resources:
- ../../base
patchesStrategicMerge:
- map.yaml
EOF
```

#### Staging Patch

Add a configMap customization to change the server
greeting from _Good Morning!_ to _Have a pineapple!_

Also, enable the _risky_ flag.

```sh
cat <<EOF >$OVERLAYS/staging/map.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: the-map
data:
  altGreeting: "Have a pineapple!"
  enableRisky: "true"
EOF
```

#### Production Kustomization

In the production directory, make a kustomization
with a different name prefix and labels.


```sh
cat <<EOF >$OVERLAYS/production/kustomization.yaml
namePrefix: production-
commonLabels:
  variant: production
  org: acmeCorporation
commonAnnotations:
  note: Hello, I am production!
resources:
- ../../base
patchesStrategicMerge:
- deployment.yaml
EOF
```


#### Production Patch

Make a production patch that increases the replica
count (because production takes more traffic).


```sh
cat <<EOF >$OVERLAYS/production/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: the-deployment
spec:
  replicas: 10
EOF
```

## Compare overlays


`DEMO_HOME` now contains:

 - a _base_ directory - a slightly customized clone
   of the original configuration, and

 - an _overlays_ directory, containing the kustomizations
   and patches required to create distinct _staging_
   and _production_ [variants] in a cluster.

Review the directory structure and differences:

```
tree $DEMO_HOME
```

Expecting something like:

> ```
> lab1_2_helloworld
> ├── base
> │   ├── configMap.yaml
> │   ├── deployment.yaml
> │   ├── kustomization.yaml
> │   └── service.yaml
> └── overlays
>     ├── production
>     │   ├── deployment.yaml
>     │   └── kustomization.yaml
>     └── staging
>         ├── kustomization.yaml
>         └── map.yaml
> ```

Compare the output directly
to see how _staging_ and _production_ differ:


```
diff \
  <(kustomize build $OVERLAYS/staging) \
  <(kustomize build $OVERLAYS/production) |\
  more
```

The first part of the difference output should look
something like

> ```diff
> <   altGreeting: Have a pineapple!
> <   enableRisky: "true"
> ---
> >   altGreeting: Good Morning!
> >   enableRisky: "false"
> 8c8
> <     note: Hello, I am staging!
> ---
> >     note: Hello, I am production!
> 11c11
> <     variant: staging
> ---
> >     variant: production
> 13c13
> (...truncated)
> ```


## Deploy

The individual resource sets are:


```sh
kustomize build $OVERLAYS/staging
```


```sh
kustomize build $OVERLAYS/production
```

To deploy, pipe the above commands to kubectl apply:

> ```sh
> kustomize build $OVERLAYS/staging |\
>     kubectl apply -f -
> ```

> ```sh
> kustomize build $OVERLAYS/production |\
>    kubectl apply -f -
> ```
