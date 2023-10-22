# Install Istio using `istioclt`
## Create GKE cluster

```sh
gcloud container clusters create my-istio-cluster \
  --zone "asia-southeast1-a" \
  --cluster-version latest \
  --machine-type "n1-standard-2" \
  --num-nodes "3" \
  --network "default"
```

## Download Istio

1. Download the Istio release binary:

```sh
export ISTIO_VERSION=1.17.6
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
```
2. Add the istioctl client to the PATH:

```
export PATH=$PWD/istio-${ISTIO_VERSION}/bin:$PATH
```
3. Check istioctl version:

```sh
istioctl version
```

4. Check if your Kubernetes environment meets Istio's platform requirement:

```sh
istioctl x precheck
```
The precheck response should indicate that no issues were found:
```t
✔ No issues found when checking the cluster. Istio is safe to install or upgrade!
  To get started, check out https://istio.io/latest/docs/setup/getting-started/
```

## Install Istio
1. List available installation profiles:

```sh
istioctl profile list
```

2. Since this is a getting started lab, you will use the `demo` profile to install Istio.

```
istioctl install --set profile=demo -y
```
You should see output that indicates each Istio component is installed successfully. 
```t
✔ Istio core installed                                                                                                                                                                                                                        
✔ Istiod installed                                                                                                                                                                                                                             
✔ Egress gateways installed                                                                                                                                                                                                                    
✔ Ingress gateways installed                                                                                                                                                                                                                   
✔ Installation complete  
```

3. Check out the resources installed by Istio:

```sh
kubectl get all,cm,secrets,envoyfilters -n istio-system
```
4. Check out `Custom Resource Definitions` (CRDs) installed by Istio:

```sh
kubectl get crds -n istio-system
```
5. Verify the installation using the following command:

```sh
istioctl verify-install
```
You should see the following at the end of the output to indicate that your Istio is installed successfully:

```t
✔ Istio is installed and verified successfully
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

7. Access the Kiali UI at http://0.0.0.0:20001/kiali, and you should be able to view the `Kiali UI`. Press `ctrl+C` to end the prior command. You will not see much telemetry data on any of these dashboards now, as you don't have any services defined in the Istio service mesh yet. You will revisit these dashboards soon.

## Uninstall Istio

```sh
istioctl uninstall --purge
```