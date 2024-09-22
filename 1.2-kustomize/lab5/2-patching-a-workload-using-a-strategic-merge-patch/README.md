# PURPOSE

The purpose of this lab is to use Kustomize to patch the app's Deployment definition, so that it references the generated ConfigMap that holds the `SQLITE_DB_LOCATION` variable and its value.

# REQUIREMENTS

This lab simply requires an installation of the Kustomize standalone binary ([https://github.com/kubernetes-sigs/kustomize/releases](https://github.com/kubernetes-sigs/kustomize/releases)).

# STEPS

1. Reset the base configuration back to its original form. Remove the `envFrom` field from the Deployment in the `base`:

  ```yaml
  envFrom:
    - configMapRef:
      name: db
  ```

  Remove the `configMapGenerator` syntax from the Kustomization in the `base`:

  ```yaml
  configMapGenerator:
    - name: db
      literals:
        - SQLITE_DB_LOCATION=/tmp/db/todo.db
  ```

2. Add the `configMapGenerator` syntax to the Kustomization in the `overlay`.

  ```yaml
  configMapGenerator:
    - name: db
      literals:
        - SQLITE_DB_LOCATION=/tmp/db/todo.db
  ```

3. Review the content of the Strategic Merge patch in the overlay directory. Satisfy yourself that it contains the necessary YAML syntax to allow Kustomize to identify the Deployment as the definition to patch.

  ```sh
  cd config/before/overlay
  cat deployment.env.patch.yaml
  ```

4. Define the patch in the overlay Kustomization, so that it gets included in builds. It should look like this:

  ```yaml
  ---
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization

  <snip>

  patches:
    - path: deployment.env.patch.yaml

  <snip>
  ```

5. Perform a build of the revised Kustomization in the overlay, and satisfy yourself that it contains the generated ConfigMap, and that the same is referenced in the app's Deployment definition.

  ```sh
  kustomize build .
  ```

6. Re-perform the build and save the output for a comparison in the next exercise.

  ```sh
  AFTER_PATCH_ONE="$(mktemp -d -p /tmp)"
  kustomize build . -o $AFTER_PATCH_ONE
  ```

Well now, you just defined your first Kustomize patch - a Strategic Merge patch! Notice that you didn't need to define a target, as there is enough information in the patch for Kustomize to work out what it needs to apply the patch to.
