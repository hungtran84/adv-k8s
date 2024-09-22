# PURPOSE

The purpose of this lab is to use Kustomize to create a new overlay that swaps out the SQLite database for a MySQL instance instead. The example app has a pluggable persistence layer, and takes its cue from configuration in the environment. Setting up MySQL in place of SQLite is more complicated, but we should provide the means of choosing between the two.

# REQUIREMENTS

This lab simply requires an installation of the Kustomize standalone binary ([Kustomize Releases](https://github.com/kubernetes-sigs/kustomize/releases)). If you plan to deploy the app to test it out, you'll also need to have a Kubernetes cluster available, as well as the kubectl CLI installed. Information for installing kubectl is [here](https://kubectl.docs.kubernetes.io/installation/kubectl/).

# STEPS

1. Become familiar with the mechanism the app uses to determine if it needs to interact with a SQLite database or a MySQL instance for persistence.

    ```sh
    cd app
    cat src/persistence/index.js
    ```

2. Determine how the directory structure that Kustomize operates on has been altered to account for the introduction of the new 'qa' overlay. Notice the new base configuration for MySQL and the introduction of the new overlay.

    ```sh
    cd ../config
    ls -lR
    ```

3. Inspect the contents of the directory that is the Kustomization root for the new 'qa' overlay. Try to understand how the configuration all hangs together.

    ```sh
    cd overlays/qa
    cat persistent-volume*
    cat secrets/*
    cat patches/mysql.volumes.patch.yaml
    cat patches/todo.volumes.patch.yaml
    cat kustomization.yaml
    ```

4. If you have a Kubernetes cluster available to test the rendered config, perform a build and send the output to `kubectl apply`.

    ```sh
    kustomize build . | kubectl apply -f -
    ```

5. Check that the app has been deployed as expected.

    ```sh
    kubectl -n qa get all
    ```

    Depending on how you have exposed the app beyond the cluster, use an IP address to consume the app in a web browser. If this is a struggle to do, you can always use `kubectl port-forward` ([kubectl port-forward](https://bit.ly/3rLOz68)) instead.

6. In preparation for the next exercise, where a comparison will be made with the output of this 'qa' overlay Kustomization, save the rendered build output in a temporary directory.

    ```sh
    QA_BEFORE="$(mktemp -d -p /tmp)"
    kustomize build . -o $QA_BEFORE
    ```

With the introduction of this new overlay, we've drastically altered the way the app is configured. This configuration is equally as valid as that defined in the `dev` overlay. How can we use Kustomize to provide options for the way the app is configured for different environments ... without repeating stuff?
