# PURPOSE

The purpose of this lab is to use **Kustomize** to add a label to the metadata of the example app's configuration in an overlay. This lab will also add a common label to the configuration, specifically a label for the metadata, template, and selectors of different objects.

# REQUIREMENTS

This lab requires the installation of the **Kustomize standalone binary**. You can download it from [Kustomize releases](https://github.com/kubernetes-sigs/kustomize/releases). You can compare the rendered configurations manually in separate terminals or use a diffing tool like [delta](https://dandavison.github.io/delta/installation). To install delta for your OS, refer to the provided link.

# STEPS

1. Add the label transformer syntax to the overlay Kustomization:

    ```bash
    cd config/before/overlay
    ```

    The Kustomization should now look like this:

    ```yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    resources:
      - ../base
      - namespace.yaml
    buildMetadata:
      - managedByLabel
    namespace: dev
    labels:
      - pairs:
          app.kubernetes.io/env: dev
    commonLabels:
      app.kubernetes.io/version: v1.0
    ```

2. Create some temporary directories to store the rendered output for builds of the base and overlay Kustomizations:

    ```bash
    cd ..
    BASE="$(mktemp -d -p /tmp)"
    OVERLAY="$(mktemp -d -p /tmp)"
    ```

3. Use Kustomize to perform builds of the base and overlay Kustomizations, saving the output in each case in the relevant temporary directory:

    ```bash
    kustomize build base -o $BASE
    kustomize build overlay -o $OVERLAY
    ```

4. Compare the two builds and confirm that the labels have been added to the relevant objects in the right places. Pay particular attention to the different treatment applied by the LabelTransformer for the various convenience fields used:

    ```bash
    delta -s $BASE $OVERLAY
    ```

Congratulations! You've now used Kustomize's LabelTransformer to manipulate the labels of the objects in an overlay Kustomization. If you're feeling adventurous, you might try out the built-in transformer to selectively apply a label to one or more of the Deployment and Service objects. Good luck!
