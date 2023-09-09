# Managing and deploying workloads with Lens

## Deploy a deployment using Template

- Deploying a `hello-world` deployment from template

![Alt text](image.png)


![Alt text](image-1.png)


![Alt text](image-2.png)

- Hit `Create and Close` to deploy your deployment to the cluster. 3 pods should be up and running after few seconds.

![Alt text](image-3.png)

## Deploy your `workpress` with helm chart

- Create namespace

![Alt text](image-4.png)

- Go to `Helm -> Charts` and search for `wordpress`

![Alt text](image-5.png)

- Pick up the first one and check for further Chart info

![Alt text](image-6.png)

- Hit `Install` and Lens IDE shows up again

![Alt text](image-7.png)

- Modify chart default values as below and hit `Install`

![Alt text](image-8.png)

- Check Chart NOTES after installation

![Alt text](image-9.png)

- Get the WordPress URL by running these commands

```shell
export SERVICE_IP=$(kubectl get svc --namespace wordpress wordpress-dev --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "WordPress URL: http://$SERVICE_IP/"
echo "WordPress Admin URL: http://$SERVICE_IP/admin"
echo Username: user
echo Password: $(kubectl get secret --namespace wordpress wordpress-dev -o jsonpath="{.data.wordpress-password}" | base64 -d)


Username: user
Password: xxxx
WordPress URL: http://35.240.238.55/
WordPress Admin URL: http://35.240.238.55/admin
```

- Open a browser and access WordPress using the obtained URL

![Alt text](image-10.png)

- Login to Wordpress Admin page

![Alt text](image-11.png)

![Alt text](image-12.png)

- Cleanup `Wordpress`

![Alt text](image-13.png)


![Alt text](image-14.png)
