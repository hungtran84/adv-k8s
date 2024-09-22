# Purpose

The purpose of this lab is to use Kustomize to patch the app's Deployment definition, so that it removes the security context used to force the pod to run as the root user. The patch will be a JSON patch this time. The build output will be compared with the output generated in the previous exercise.

# Requirements

This lab simply requires an installation of the Kustomize standalone binary ([Kustomize Releases](https://github.com/kubernetes-sigs/kustomize/releases)). A comparison of the rendered configurations can be made manually in separate terminals, or you can use a diffing tool like 'delta' to make the comparison. To install delta for your OS, see [Delta Installation](https://dandavison.github.io/delta/installation).

# Steps

1. Add a patch to the Kustomization in the overlay to remove the security context. Define the patch as a JSON patch. It should look like this:

  ```yaml
  ---
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization

  <snip>

  patches:
    - patch: |-
      - op: remove
        path: /spec/template/spec/securityContext
    target:
      kind: Deployment
      name: todo
  ```

2. Perform a build of the Kustomization, and save its output into a temporary directory for comparison with the build from the previous exercise.

  ```sh
  AFTER_PATCH_TWO="$(mktemp -d -p /tmp)"
  kustomize build . -o $AFTER_PATCH_TWO
  ```

3. Make a comparison of the two builds, and confirm that the only difference between the builds is the presence of the security context in the build that contains only the Strategic Merge patch.

  ```sh
  delta -s $AFTER_PATCH_ONE $AFTER_PATCH_TWO
  ```

This time around you've applied a JSON patch to remove some configuration inherited from the base. Unlike a Strategic Merge patch, it was necessary to supply a target object for Kustomize to apply the JSON patch to.
