# PURPOSE

The purpose of this lab is to use **Kustomize** to change the namespace in the metadata of the example app's configuration. The namespace is undefined in the base, but the overlay will set the namespace value for all objects to `dev`. Optionally, you can test the configuration by applying the rendered output to a Kubernetes cluster.

# REQUIREMENTS

This lab requires an installation of the **Kustomize standalone binary**. You can download it from [Kustomize releases](https://github.com/kubernetes-sigs/kustomize/releases). If you plan to deploy the app to test it, you’ll need access to a Kubernetes cluster and the **kubectl CLI** installed. Installation instructions for kubectl can be found [here](https://kubectl.docs.kubernetes.io/installation/kubectl/).

# STEPS

1. **Create a Namespace object definition** to use as a Kustomize resource. You can either create it manually or use the `kubectl create` command:

    ```bash
    cd config/before/overlay
    kubectl create namespace dev --dry-run=client -o yaml > namespace.yaml
    cat namespace.yaml
    ```

2. **Amend the overlay Kustomization** to include the new resource and set the namespace for all resources in the scope of the Kustomization. The `kustomization.yaml` file should look like this:

    ```yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    resources:
      - ../base
      - namespace.yaml
    buildMetadata:
      - managedByLabel
    namespace: dev
    ```

3. **Build the Kustomization** in the overlay directory and verify its content includes the Namespace, and that all objects have their namespace set to `dev`:

    ```bash
    kustomize build .
    ```

4. **(Optional)** If you have a Kubernetes cluster available, **apply the rendered configuration** to test it:

    ```bash
    kustomize build . | kubectl apply -f -
    ```

5. **Check that the app has been deployed** as expected:

    ```bash
    kubectl -n dev get all
    ```

---

Congratulations! You've used the **NamespaceTransformer** to modify the base configuration of the app in an overlay variant. This is the first of the metadata transformers you'll be working with. We'll explore more metadata transformers as we proceed.
