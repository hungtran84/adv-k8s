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

6. Access the `Prometheus UI` at http://0.0.0.0:9090 , you should be able to view the Prometheus UI from there. Press `ctrl+C` to end the prior command, and use the command below to enable access to the `Grafana` dashboard:

```sh
istioctl dashboard prometheus --browser=false --address 0.0.0.0
```

7. Access the Grafana dashboard at http://0.0.0.0:3000, and you should be able to view the `Grafana UI`. Press `ctrl+C` to end the prior command, and use the command below to enable access to the `Jaeger` dashboard:

```sh
istioctl dashboard grafana --browser=false --address 0.0.0.0
```

8. Access the Jaeger UI at http://0.0.0.0:16686, and you should be able to view the `Jaeger UI`. Press `ctrl+C` to end the prior command, and use the command below to enable access to the `Kiali` dashboard:

```sh
istioctl dashboard jaeger --browser=false --address 0.0.0.0
```

9. Access the Kiali UI at http://0.0.0.0:20001/kiali, and you should be able to view the `Kiali UI`. Press `ctrl+C` to end the prior command. You will not see much telemetry data on any of these dashboards now, as you don't have any services defined in the Istio service mesh yet. You will revisit these dashboards soon.

```sh
istioctl dashboard kiali --browser=false --address 0.0.0.0
```

## Uninstall Istio

```sh
helm uninstall istiod -n istio-system
helm uninstall istio-base -n istio-system
```