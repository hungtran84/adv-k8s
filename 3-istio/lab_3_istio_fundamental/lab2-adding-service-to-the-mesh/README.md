# Adding Services to the Mesh
In this lab, you will incrementally add services to the mesh. The mesh is actually integrated with the services themselves which makes it mostly transparent to the service implementation.

## Sidecar injection
Adding services to the mesh requires that the client-side proxies be associated with the service components and registered with the control plane. With Istio, you have two methods to inject the Envoy Proxy sidecar into the microservice Kubernetes pods:
- Automatic sidecar injection
- Manual sidecar injection.

1.To enable the automatic sidecar injection, use the command below to add the istio-injection label to the istioinaction namespace:

    ```sh
    kubectl label namespace istioinaction istio-injection=enabled
    ```

2. Validate the istioinaction namespace is annotated with the istio-injection label:

    ```
    kubectl get namespace -L istio-injection
    ```
Now that you have an `istioinaction` namespace with automatic sidecar injection enabled, you are ready to start adding services in your `istioinaction` namespace to the mesh. Since you added the istio-injection label to the `istioinaction` namespace, the Istio mutating admission controller automatically injects the Envoy Proxy sidecar during the initial deployment or restart of the pod.

## Review Service requirements
Before you add Kubernetes services to the mesh, you need to be aware of the application requirements to ensure that your Kubernetes services meet the minimum requirements.

Service descriptors:
- each service port name must start with the protocol name, for example `name: http`

Deployment descriptors:

- The pods must be associated with a Kubernetes service.
- The pods must not run as a user with UID 1337
- App and version labels are added to provide contextual information for metrics and tracing

Check the above requirements for each of the Kubernetes services and make adjustments as necessary. If you don't have `NET_ADMIN` security rights, you would need to explore the Istio CNI plugin to remove the `NET_ADMIN` requirement for deploying services.

Using the `web-api` service as an example, you can review its service and deployment descriptor:

```
cat sample-apps/web-api.yaml
```

From the service descriptor, the `name: http` declares the http protocol for the service port 8080:
```yaml
  - name: http
    protocol: TCP
    port: 8080
    targetPort: 8081
```

From the deployment descriptor, the `app: web-api` label matches the `web-api` service's selector of `app: web-api` so this deployment and its pod are associated with the `web-api` service. Further, the `app: web-api` label and `version: v1` labels provide contextual information for metrics and tracing. The `containerPort: 8081` declares the listening port for the container, which matches the `targetPort: 8081` in the `web-api` service descriptor earlier.

```yaml
  template:
    metadata:
      labels:
        app: web-api
        version: v1
      annotations:
    spec:
      serviceAccountName: web-api
      containers:
      - name: web-api
        image: nicholasjackson/fake-service:v0.7.8
        ports:
        - containerPort: 8081
```
Check the `purchase-history-v1`, `recommendation`, and `sleep` services to validate they all meet the above requirements.

## Adding services to the mesh
You can add a sidecar to each of the services in the istioinaction namespace, starting with the `web-api` service:

```
kubectl rollout restart deployment web-api -n istioinaction
```

Validate the `web-api` pod is running with Istio's default sidecar proxy injected:

```
kubectl get pod -l app=web-api -n istioinaction
```
You should see 2/2 in the output. This indicates the sidecar proxy is running alongside the `web-api` application container in the `web-api` pod:

```
NAME                       READY   STATUS    RESTARTS   AGE
web-api-7d5ccfd7b4-m7lkj   2/2     Running   0          9m4s
```

3. Validate the web-api pod log looks good:

    ```
    kubectl logs deploy/web-api -c web-api -n istioinaction
    ```
4. Validate you can continue to call the web-api service securely:

    ```
    curl --cacert ./labs/02/certs/ca/root-ca.crt -H "Host: istioinaction.io" https://istioinaction.io:$SECURE_INGRESS_PORT --resolve istioinaction.io:$SECURE_INGRESS_PORT:$GATEWAY_IP
    ```

## Understand what happens
Use the command below to get the details of the `web-api` pod:

```
kubectl get pod -l app=web-api -n istioinaction -o yaml
```

From the output, the `web-api` pod contains 1 init container and 2 normal containers. The Istio mutating admission controller was responsible for injecting the istio-init container and the istio-proxy container.

The `istio-init` container:
The `istio-init` container uses the `proxyv2` image. The entry point of the container is `pilot-agent`, which contains the `istio-iptables` command to set up port forwarding for Istio's sidecar proxy.
```yaml
    initContainers:
    - args:
      - istio-iptables
      - -p
      - "15001"
      - -z
      - "15006"
      - -u
      - "1337"
      - -m
      - REDIRECT
      - -i
      - '*'
      - -x
      - ""
      - -b
      - '*'
      - -d
      - 15090,15021,15020
      image: docker.io/istio/proxyv2:latest
      imagePullPolicy: Always
      name: istio-init
```

Interested in knowing more about the flags for `istio-iptables`? Run the following command:

```
kubectl exec deploy/web-api -c istio-proxy -n istioinaction -- /usr/local/bin/pilot-agent istio-iptables --help
```

The output explains the flags such as `-u`, `-m`, and `-i` which are used in the `istio-init` container's args. You will notice that all inbound ports are redirected to the Envoy Proxy container within the pod. You can also see a few ports such as `15021` which are excluded from redirection (you'll soon learn why this is the case). You may also notice the following `securityContext` for the `istio-init` container. This means that a service deployer must have the `NET_ADMIN` and `NET_RAW` security capabilities to run the `istio-init` container for the `web-api` service or other services in the Istio service mesh. If the service deployer can't have these security capabilities, you can use the Istio CNI plugin which removes the `NET_ADMIN` and `NET_RAW` requirement for users deploying pods into Istio service mesh.

The `istio-proxy` container:

When you continue looking through the list of containers in the pod, you will see the `istio-proxy` container. The `istio-proxy` container also uses the `proxyv2` image. You'll notice the `istio-proxy` container has requested 0.01 CPU and 40 MB memory to start with as well as 2 CPU and 1 GB memory for limits. You will need to budget for these settings when managing the capacity for the cluster. These resources can be customized during the Istio installation thus may vary per your installation profile.

When you reviewed the `istio-init` container configuration earlier, you may have noticed that ports `15021`, `15090`, and `15020` are on the list of inbound ports to be excluded from redirection to Envoy. The reason is that port `15021` is for health check, and port `15090` is for the Envoy Proxy to emit its metrics to Prometheus, and port `15020` is for the merged Prometheus metrics colllected from the Istio agent, the Envoy Proxy, and the application container. Thus it is not necessary to redirect inbound traffic for these ports since they are being used by the `istio-proxy` container.

Also notice that the `istiod-ca-cert` and `istio-token` volumes are mounted on the pod for the purpose of implementing mutual TLS (`mTLS`), which will be covered in the next lab.

## Add more services to the Istio service mesh
1. Next, you can add the `istio-proxy` sidecar to the other services in the `istioinaction` namespace

    ```
    kubectl rollout restart deployment purchase-history-v1 -n istioinaction
    kubectl rollout restart deployment recommendation -n istioinaction
    kubectl rollout restart deployment sleep -n istioinaction
    ```

2. Validate that all the pods in the `istioinaction` namespace are running with Istio's default sidecar proxy injected:

    ```
    kubectl get pods -n istioinaction
    ```

3. Validate that you can continue to call the web-api service securely:

    ```
    curl --cacert ./labs/02/certs/ca/root-ca.crt -H "Host: istioinaction.io" https://istioinaction.io:$SECURE_INGRESS_PORT --resolve istioinaction.io:$SECURE_INGRESS_PORT:$GATEWAY_IP
    ```
