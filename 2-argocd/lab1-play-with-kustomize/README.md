# Play with Kustomize

## Declarative Configuration in Kubernetes

- `Kustomize` is a very powerful tool for customizing and building Kubernetes resources.
- `Kustomize` started at 2017. Added to `kubectl` since version 1.14.
- `Kustomize` has many useful features for managing and deploying resource.
- When you execute a Kustomization beside using the build-in features it will also re-order the resources in a logical way for the K8S to be deployed.

### Re-order the resources for

- `Kustomization` re-order the `Kind` for optimization, for example we will need an existing `namespace` before using it.

- The order of the resources is defined in the source code:
  Source: https://github.com/kubernetes-sigs/kustomize/blob/master/api/resid/gvk.go

```go
// An attempt to order things to help k8s, e.g.
// - Namespace should be first.
// - Service should come before things that refer to it.
// In some cases order just specified to provide determinism.
var orderFirst = []string{
	"Namespace",
	"ResourceQuota",
	"StorageClass",
	"CustomResourceDefinition",
	"ServiceAccount",
	"PodSecurityPolicy",
	"Role",
	"ClusterRole",
	"RoleBinding",
	"ClusterRoleBinding",
	"ConfigMap",
	"Secret",
	"Endpoints",
	"Service",
	"LimitRange",
	"PriorityClass",
	"PersistentVolume",
	"PersistentVolumeClaim",
	"Deployment",
	"StatefulSet",
	"CronJob",
	"PodDisruptionBudget",
}

var orderLast = []string{
	"MutatingWebhookConfiguration",
	"ValidatingWebhookConfiguration",
}
```

### Base resource for our lab
- In the following samples we will refer to the following `base.yaml` file

```yaml
# These are the base files for all the labs in this folder
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: __image__

---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
  labels:
    app: postgres
spec:
  selector:
    app: postgres
  # Service of type NodePort
  type: NodePort
  # The default port for postgres
  ports:
    - port: 5432

---
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: tokp01

resources:
  - deployment.yaml
  - service.yaml
```

---
## Common Features

- [Play with Kustomize](#play-with-kustomize)
  - [Declarative Configuration in Kubernetes](#declarative-configuration-in-kubernetes)
    - [Re-order the resources for](#re-order-the-resources-for)
    - [Base resource for our lab](#base-resource-for-our-lab)
  - [Common Features](#common-features)
  - [`commonAnnotation`](#commonannotation)
  - [`commonLabels`](#commonlabels)
  - [Generators](#generators)
    - [`configMapGenerator`](#configmapgenerator)
  - [`Secret` Generator](#secret-generator)
  - [`images`](#images)
  - [`Namespaces`](#namespaces)
    - [`Prefix-suffix`](#prefix-suffix)
  - [`Replicas`](#replicas)
  - [Patches](#patches)
    - [Patch Add/Update](#patch-addupdate)
    - [Patch-Delete](#patch-delete)
    - [Patch Replace](#patch-replace)

---

## `commonAnnotation`

```sh
kubectl kustomize samples/01-commonAnnotation
```

```yaml
### FileName: kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# This will add annotation under every metadata entry
# ex: main metadata, spec.metadata etc
commonAnnotations:
  author: hungtran177@gmail.com
```

- Output:

  ```yaml
  ### commonAnnotation output
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    annotations:
      ### Annotation added here
      author: hungtran177@gmail.com
      name: myapp
  spec:
    selector:
      matchLabels:
        app: myapp
    template:
      metadata:
        ### Annotation added here
        annotations:
          author: hungtran177@gmail.com
        labels:
          app: myapp
      spec:
        containers:
          - image: __image__
            name: myapp
  ```

## `commonLabels`

```sh
kubectl kustomize samples/02-commonLabels
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# This will add annotation under every metadata entry
# ex: main metadata, spec.metadata etc
commonLabels:
  author: hungtran177@gmail.com
  env: qa

resources:
  - ../_base
```

- Output:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
      # Labels added ....
      labels:
      author: hungtran177@gmail.com
      env: qa
    name: myapp
  spec:
    selector:
      matchLabels:
        app: myapp
        # Labels added ....
        author: hungtran177@gmail.com
        env: qa
    template:
      metadata:
        labels:
          app: myapp
          # Labels added ....
          author: hungtran177@gmail.com
          env: qa
      spec:
        containers:
        - image: __image__
          name: myapp
  ```

## Generators
- Kustomization also support generate `ConfigMap` / `Secret` in several ways.
- The default behavior is adding the output hash value as suffix to the name, 
  ex: `secretMapFromFile-495dtcb64g`
    ```yaml
    apiVersion: v1
    data:
      APP_ENV: ZGV2ZWxvcG1lbnQ=
      LOG_DEBUG: dHJ1ZQ==
      NODE_ENV: ZGV2
      REGION: d2V1
    kind: Secret
    metadata:
      name: secretMapFromFile-495dtcb64g # <--------------------------
    type: Opaque
    ```
- We can disable the suffix with the following addition to the `kustomization.yaml`
  ```yaml
  generatorOptions:
    disableNameSuffixHash: true
  ```
### `configMapGenerator`

  - #### FromEnv
    - `.env`
      ```sh
      key1=value1
      env=qa
      ```
    - `kustomization.yaml`
      ```yaml
      # Generate config file from env file
      configMapGenerator:
        - name: configMapFromEnv
          env: .env
      ```
    - Generate the configMap
      ```sh
      kubectl kustomize samples/03-generators/ConfigMap/01-FromEnv
      ```
  - #### FromFile
      - Generate the configMap
      ```sh
      kubectl kustomize samples/03-generators/ConfigMap/02-FromFile
      ```
    - `.env`
      ```sh
      key1=value1
      env=qa
      ```
    - `kustomization.yaml`
      ```yaml
      # Generate config file from env file
      configMapGenerator:
        - name: configMapFromEnv
          files: 
          - .env
      ```

    - The output of `configMapFromEnv`:
      ```yaml
      apiVersion: v1
      data:
        .env: |-
          key1=value1
          env=qa
      kind: ConfigMap
      metadata:
        name: configFromFile-bmfhm27g86
      ```
  - #### FromLiteral
      - Generate the configMap
      ```sh
      kubectl kustomize samples/03-generators/ConfigMap/03-FromLiteral
      ```
    - `.env`
      ```sh
      key1=value1
      env=qa
      ```
    - `kustomization.yaml`
      ```yaml
      configMapGenerator:
        - name: configFromLiterals
          literals:
            - Key1=value1
            - Key2=value2
      ```

    - The output of `configMapFromEnv`:
      ```yaml
      apiVersion: v1
      data:
        Key1: value1
        Key2: value2
      kind: ConfigMap
      metadata:
        name: configFromLiterals-82895k6m2b
      ```
---

## `Secret` Generator
```sh
kubectl kustomize samples/03-generators/Secret
```
```yaml
# Similar to configMap but with additional type field
secretGenerator:
  # Generate secret from env file
  - name: secretMapFromFile
    env: .env
    type: Opaque
generatorOptions:
  disableNameSuffixHash: true # Disable suffix hash
```
## `images`

- Modify the name, tags and/or digest for images.

```sh
kubectl kustomize samples/04-images
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ./base.yaml

images:
  # The image as its defined in the Deployment file
  - name: __image__
    # The new name to set
    newName: my-registry/my-image
    # optional: image tag
    newTag: v1
```

- Output:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: myapp
  spec:
    selector:
      matchLabels:
        app: myapp
    template:
      metadata:
        labels:
          app: myapp
      spec:
        containers:
          # --- This image was updated
          - image: my-registry/my-image:v1
            name: myapp
  ```

---

## `Namespaces`

```sh
kubectl kustomize samples/05-Namespace
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Add the desired namespace to all resources
namespace: kustomize-namespace

resources:
  - ../_base
```

- Output:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: myapp
    # Namespace added here
    namespace: kustomize-namespace
  ```

---

### `Prefix-suffix`

```sh
kubectl kustomize samples/06-Prefix-Suffix
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Add the desired Prefix to all resources
namePrefix: prefix-tokp01-
nameSuffix: -suffix-tokp01

resources:
  - ../_base
```

- Output:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: prefix-tokp01-myapp-suffix-tokp01
  ```

---

## `Replicas`

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment
spec:
  replicas: 5
  selector:
    name: deployment
  template:
    containers:
      - name: container
        image: registry/conatiner:latest
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

replicas:
  - name: deployment
    count: 10

resources:
  - deployment.yaml
```

- Output:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment
spec:
  replicas: 10
  selector:
    name: deployment
  template:
    containers:
      - image: registry/conatiner:latest
        name: container
```

---

## Patches
- There are several types of patches like [`replace`, `delete`, `patchesStrategicMerge`]
- For this lab we will demonstrate `patchesStrategicMerge`

### Patch Add/Update

```sh
kubectl kustomize samples/08-Patches/patch-add-update
```

```yaml
# File: patch-memory.yaml
# -----------------------
# Patch limits.memory
apiVersion: apps/v1
kind: Deployment
# Set the desired deployment to patch
metadata:
  name: myapp
spec:
  # patch the memory limit
  template:
    spec:
      containers:
        - name: patch-name
          resources:
            limits:
              memory: 512Mi
```

```yaml
# File: patch-replicas.yaml
# -------------------------
apiVersion: apps/v1
kind: Deployment
# Set the desired deployment to patch
metadata:
  name: myapp
spec:
  # This is the patch for this lab
  replicas: 3
```  

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../_base
  
patches:
- path: patch-memory.yaml
- path: patch-replicas.yaml
- path: patch-service.yaml
```

- Output:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  # This is the first patch
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      # This is the second patch
      containers:
      - name: patch-name
        resources:
          limits:
            memory: 512Mi
      - image: __image__
        name: myapp
      - image: nginx
        name: nginx
```

### Patch-Delete
```sh
kubectl kustomize samples/08-Patches/patch-delete
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../_base
  
patches:
- path: patch-delete.yaml
```

```yaml
# patch-delete.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
        # Remove this section, in this demo it will remove the 
        # image with the `name: myapp` 
        - $patch: delete
          name: myapp
          image: __image__
```

- Output:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - image: nginx
        name: nginx
```

### Patch Replace
```sh
kubectl kustomize samples/08-Patches/patch-replace/
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../_base
  
patches:
- path: patch-replace-ports.yaml
- path: patch-replace-image.yaml
```

```yaml
# patch-replace-image.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
        # Remove this section, in this demo it will remove the 
        # image with the `name: myapp` 
        - $patch: replace
        - name: myapp
          image: nginx:latest
          args:
          - one
          - two
```

```yaml
# patch-replace-ports.yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: postgres
  labels:
    app: postgres
spec:
  selector:
    app: postgres
  $patch: replace
  # Replace the current ports with port 80
  ports:
    - port: 80
```

- Output:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - args:
        - one
        - two
        image: nginx:latest
        name: myapp
```
