# PURPOSE

The purpose of this lab is to use Kustomize to redefine the container image name used by the application in the `dev` overlay. This shows us how to cater for different app versions, according to the environment it is intended to be deployed to.

# REQUIREMENTS

This lab simply requires an installation of the Kustomize standalone binary ([Kustomize Releases](https://github.com/kubernetes-sigs/kustomize/releases)). A comparison of the rendered configurations can be made manually in separate terminals, or you can use a diffing tool like 'delta' to make the comparison. To install delta for your OS, see [Delta Installation](https://dandavison.github.io/delta/installation).

# STEPS

1. Reacquaint yourself with the content of the Kustomization defined in the overlay. It's identical to the previous time it was used.

  ```sh
  cd config/before/overlay
  cat kustomization.yaml
  ```

2. Perform a build of the Kustomization, and save its output into a temporary directory for future comparison.

  ```sh
  BEFORE="$(mktemp -d -p /tmp)"
  kustomize build . -o $BEFORE
  ```

3. Create a temporary directory to store the build output from a coming build, so that it can be subsequently compared with build output we've just saved.

  ```sh
  AFTER="$(mktemp -d -p /tmp)"
  ```

4. Define an image tag transformation in the overlay, so as to alter the tag of the app's container from 'v1.0' to 'dev'. It should look like this:

  ```yaml
  ---
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
  images:
    - name: ghcr.io/username/todo
      newTag: dev
      newName: ghcr.io/yourname/todo
      digest: sha256:abc123def456
  ```

5. Perform a build of the revised Kustomization in the overlay, and save the output in the temporary directory you just created.

  ```sh
  kustomize build . -o $AFTER
  ```

1. Make a comparison of the two builds, and confirm that the container's image tag, image name and digest are the items of configuration that have been altered between the builds. 

  ```sh
  delta -s $BEFORE $AFTER
  ```

You can see how straightforward it is to change aspects of a workload's image, whether that's name, tag or digest. Maybe have a go at changing other parts of the image name; registry host, namespace, repo and so on?
