# PURPOSE

The purpose of this lab is to use **Kustomize** to create a variant of the Kubernetes configuration for the example app used throughout the course. The original configuration will serve as the base, and the variant will be created from a Kustomization defined in an overlay.

# REQUIREMENTS

This lab requires the installation of the **Kustomize standalone binary**. You can download it from [Kustomize releases](https://github.com/kubernetes-sigs/kustomize/releases).

You may need to install `tree` command for better visibility of `kustomize` folder structure

```bash
# CloudShell
sudo apt-get install tree
```

```bash
# MacOS
brew install tree
```
# STEPS

1. Familiarize yourself with the directory structure and its initial content:

    ```bash
    cd config
    ls -lR
    tree .
    ```

2. Create a Kustomization in the base directory:

    ```bash
    cd before/base
    kustomize create --autodetect
    ```

3. Inspect the new Kustomization in the base directory:

    ```bash
    ls -l
    cat kustomization.yaml
    ```

4. Build the Kustomization in the base directory and verify its content includes the Deployment and Service, but remains unaltered:

    ```bash
    kustomize build .
    ```

5. Create a Kustomization in the overlay directory, referencing the base directory as a resource:

    ```bash
    cd ../overlay
    kustomize create --resources ../base
    ```

6. Add build metadata to the Kustomization, so that the rendered object definitions include the 'managed by' label:

    ```bash
    kustomize edit add buildmetadata managedByLabel
    ```

7. Inspect the Kustomization in the overlay directory:

    ```bash
    cat kustomization.yaml
    ```

8. Build the Kustomization in the overlay directory and check that its content includes the Deployment and Service, with the 'managed by' label added:

    ```bash
    kustomize build .
    ```

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: todo
    app.kubernetes.io/managed-by: kustomize-v5.2.1
  name: todo
spec:
  ports:
  - port: 3000
    targetPort: 3000
  selector:
    app: todo
  type: LoadBalancer
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: todo
    app.kubernetes.io/managed-by: kustomize-v5.2.1
  name: todo
spec:
  selector:
    matchLabels:
      app: todo
  template:
    metadata:
      labels:
        app: todo
    spec:
      containers:
      - image: ghcr.io/username/todo:1.0
        imagePullPolicy: IfNotPresent
        name: todo
        ports:
        - containerPort: 3000
      securityContext:
        runAsGroup: 0
        runAsUser: 0
```

    

Congratulations! You've just created your first variant of the base configuration using a Kustomize overlay. This simple transformation demonstrates Kustomize's capabilities, and we’ll build on this as we progress.
