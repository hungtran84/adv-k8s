# Install Istio using `helm`

## Prerequisites
Perform any necessary platform-specific setup.

Check the Requirements for Pods and Services.

1. Configure the Helm repository:

```sh
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
```

2. Create the namespace, `istio-system`, for the Istio components:

```sh
kubectl create namespace istio-system
```

3. Install the Istio `base` chart which contains cluster-wide Custom Resource Definitions (CRDs) which must be installed prior to the deployment of the Istio control plane:

```sh
helm install istio-base istio/base --version $ISTIO_VERSION -n istio-system --set defaultRevision=default
```

4. Validate the CRD installation with the helm ls command:

```sh
helm ls -n istio-system
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
istio-base      istio-system    1               2023-10-03 23:18:12.144454 +0700 +07    deployed        base-1.17.6     1.17.6  
```

5. Install the Istio discovery chart which deploys the istiod service:

```
helm install istiod istio/istiod --version $ISTIO_VERSION -n istio-system --wait
```

6. Install the Istio Ingress Gateway

```
helm install istio-ingressgateway istio/gateway -n istio-system
```

## Install Istio Telemetry Add-ons

1. Istio telemetry add-ons are shipped as samples, but these add-ons are optimized for quick getting started and demo purposes and not for production usage. They provides a convenient way to install telemetry components that integrate with Istio.

```sh
kubectl apply -f istio-${ISTIO_VERSION}/samples/addons
```

2. Wait till all pods in the istio-system are running:

```sh
kubectl get pods -n istio-system
```

3. Enable access to the Prometheus dashboard:

```
istioctl dashboard prometheus --browser=false --address 0.0.0.0
```

4. Access the `Prometheus UI` at http://0.0.0.0:9090 , you should be able to view the Prometheus UI from there. Press `ctrl+C` to end the prior command, and use the command below to enable access to the `Grafana` dashboard:

```sh
istioctl dashboard grafana --browser=false --address 0.0.0.0
```

5. Access the Grafana dashboard at http://0.0.0.0:3000, and you should be able to view the `Grafana UI`. Press `ctrl+C` to end the prior command, and use the command below to enable access to the `Jaeger` dashboard:

```sh
istioctl dashboard jaeger --browser=false --address 0.0.0.0
```

6. Access the Jaeger UI at http://0.0.0.0:16686, and you should be able to view the `Jaeger UI`. Press `ctrl+C` to end the prior command, and use the command below to enable access to the `Kiali` dashboard:

```sh
istioctl dashboard kiali --browser=false --address 0.0.0.0
```

## Uninstall Istio

```sh
helm uninstall istiod -n istio-system
helm uninstall istio-base -n istio-system
```