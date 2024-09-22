# PURPOSE

The purpose of this lab is to use Kustomize to create a new overlay that is subtly different from the 'qa' overlay, by adding in another Component. The overlay is the 'prod' overlay, and differentiates from the 'qa' overlay in the way it exposes the app beyond the cluster for client requests. It uses an Ingress instead of a 'LoadBalancer' service.

# REQUIREMENTS

This lab simply requires an installation of the Kustomize standalone binary ([Kustomize Releases](https://github.com/kubernetes-sigs/kustomize/releases)). If you plan to deploy the app to test it out, you'll also need to have a Kubernetes cluster available, as well as the kubectl CLI installed. Information for installing kubectl is [here](https://kubectl.docs.kubernetes.io/installation/kubectl/). In an ideal world you'll have the Nginx Ingress controller configured in the cluster ([Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)), exposed externally with a DNS name.

# STEPS

1. Inspect the `prod` Kustomization, and notice how it includes an extra Component, the Ingress Component. Notice that it also has some extra build metadata defined; an annotation which provides the origin of the element of configuration for each object.

    ```sh
    cd config/after/overlays/prod
    cat kustomization.yaml
    ```

2. Inspect the Ingress Component, too. To make this work in your own lab environment, you'll need to provide a suitable `host` in the definition of the Ingress.

    ```sh
    cd ../../components/ingress
    ls -l
    cat ingress.yaml
    cat kustomization.yaml
    ```

3. Perform a build of the `prod` Kustomization, and examine the output. Notice the new annotation with the config origin, the patched Service for the app (i.e. type is now ClusterIP), and the addition of the Ingress object.

    ```sh
    cd ../../overlays/prod
    kustomize build .
    ```

4. If you have a Kubernetes cluster available to test the rendered config, perform a build and send the output to `kubectl apply`.

    ```sh
    kustomize build . | kubectl apply -f -
    ```

5. Check that the app has been deployed as expected.

    ```sh
    kubectl -n prod get all
    kubectl -n prod get ing todo
    ```

    If you've established an Ingress controller, and it has been exposed using a Service, use the DNS name (host) defined in the ingress to consume the app in a web browser.

The `prod` overlay has used an additional component of configuration that better suits the hypothetical scenario, by introducing an Ingress into the mix. This demonstrates how Components can be selectively used to nuance the rendered configuration to suit the environment at hand. Nice!
