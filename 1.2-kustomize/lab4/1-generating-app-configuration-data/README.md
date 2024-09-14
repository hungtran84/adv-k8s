# PURPOSE

The purpose of this lab is to use Kustomize to generate a ConfigMap for the example app to consume an environment variable. In particular, we'll have the ConfigMapGenerator create the ConfigMap to supply an alternative value for the variable `SQLITE_DB_LOCATION`.

# REQUIREMENTS

This lab requires an installation of the Kustomize standalone binary ([Kustomize Releases](https://github.com/kubernetes-sigs/kustomize/releases)). It would also be advantageous to have a Kubernetes cluster available for deploying the rendered configuration to. This will also necessitate the use of the `kubectl` CLI for interacting with the cluster. Information for installing `kubectl` can be found [here](https://kubectl.docs.kubernetes.io/installation/kubectl/).

# STEPS

1. **Get familiar with the default value of the `SQLITE_DB_LOCATION` variable.**

    ```bash
    cd app
    grep SQLITE_DB_LOCATION src/persistence/sqlite.js
    ```

2. **Define the syntax for the `configMapGenerator` in the base Kustomization.**

    ```bash
    cd ../config/base
    ```

    The `kustomization.yaml` file should resemble this:

    ```yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    resources:
      - deployment.yaml
      - service.yaml

    configMapGenerator:
      - name: db
        literals:
          - SQLITE_DB_LOCATION=/tmp/todos/todo.db
    ```

3. **Reference the ConfigMap from within the Deployment definition, using the name provided in the Kustomization.**

    It should look something like this:

    ```yaml
    envFrom:
      - configMapRef:
          name: db
    ```

4. **Perform a build of the base Kustomization and check that it includes the generated ConfigMap.**

    Pay particular attention to the name, which should have a suffix appended.

    ```bash
    kustomize build .
    ```

5. **Apply the build to a Kubernetes cluster and check that the ConfigMap has provided the app with the correct value for the `SQLITE_DB_LOCATION` variable.**

    ```bash
    kustomize build . | kubectl apply -f -
    kubectl get configmaps

    POD="$(kubectl get pods -l app=todo --no-headers -o custom-columns=":metadata.name")"
    kubectl exec -it po/$POD -- printenv | grep SQLITE_DB_LOCATION
    kubectl exec -it po/$POD -- ls -l /tmp/todos/todo.db
    ```

# CONCLUSION

Congratulations! You've provided the example app with some configuration made available in the environment, using the Kustomize ConfigMapGenerator. Creating ConfigMaps with Kustomize is a breeze.
