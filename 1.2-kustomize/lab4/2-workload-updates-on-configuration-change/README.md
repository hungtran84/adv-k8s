# PURPOSE

The purpose of this lab is to use Kustomize to invoke a workload update when the data in a ConfigMap is changed. The value of the `SQLITE_DB_LOCATION` variable will be updated in the Kustomization, and the output of a new build will be applied to the cluster. This lab follows on from the previous lab.

# REQUIREMENTS

As this lab follows on from the previous lab in this module, the requirements are the same as for the previous lab.

# STEPS

1. **Change the value of the `SQLITE_DB_LOCATION` variable in the Kustomization.**

    The sub-directory should be `'db'` instead of `'todos'`.

    ```bash
    cd config/before/base
    ```

    The `kustomization.yaml` file should resemble this:

    ```yaml
    ---
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    resources:
      - deployment.yaml
      - service.yaml
    configMapGenerator:
      - name: db
        literals:
          - SQLITE_DB_LOCATION=/tmp/db/todo.db
    ```

2. **Perform a build of the base Kustomization and check that it includes the revised ConfigMap.**

    The ConfigMap should have a different suffix this time, computed from the revised data content. Verify that the reference to the ConfigMap in the Deployment definition has also been updated.

    ```bash
    kustomize build .
    ```

3. **Apply the build to a Kubernetes cluster and check that the ConfigMap has provided the app with the correct value for the `SQLITE_DB_LOCATION` variable.**

    ```bash
    kustomize build . | kubectl apply -f -
    kubectl get configmaps
    kubectl get all

    POD="$(kubectl get pods \
             -l app=todo \
             --no-headers \
             -o custom-columns=":metadata.name"
    )"

    kubectl exec -it po/$POD -- printenv | grep SQLITE_DB_LOCATION
    kubectl exec -it po/$POD -- ls -l /tmp/db/todo.db
    ```

# CONCLUSION

The change in the content of the data provides Kustomize with the opportunity to generate a new ConfigMap. This, in turn, precipitates a change to the definition of the Deployment, which results in a workload update when applied to the cluster.
