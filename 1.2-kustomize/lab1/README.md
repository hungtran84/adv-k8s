# PURPOSE

The purpose of this exercise is to get familiar with the 'todo' list app that will be used throughout the course. The simple app is based on the [Express web framework](https://expressjs.com/), has a pluggable database for persistence, and is designed to be run in containerized form.

# REQUIREMENTS

The exercise requires a working Docker installation for building a container image and for testing the application prior to its deployment to Kubernetes. Docker can be obtained through a variety of means, including [Docker Desktop](https://docs.docker.com/get-docker/), and through native OS package managers ([Docker Install](https://docs.docker.com/engine/install/)). An account with an OCI registry is also required, such as [Docker Hub](https://hub.docker.com/) or the [GitHub Container Registry](https://github.com/features/packages), or any of the public cloud providers. A Kubernetes cluster is required for deploying the application.

# STEPS

1. **Get some familiarity with the application.**

    ```bash
    cd app
    ls -lR
    cat Dockerfile
    ```

2. **Build a container image for the application.** Be sure to tag your image so that it can be pushed to the OCI registry of your choice.

    ```bash
    docker build -t ghcr.io/username/todo:1.0 .
    ```

3. **Push the image to your chosen OCI registry, remembering to login first.**

    ```bash
    docker login -u username -p password ghcr.io
    docker push ghcr.io/username/todo:1.0
    ```

4. **Check the application works by running a container.**

    ```bash
    docker run -it --rm \
      -e SQLITE_DB_LOCATION=/tmp/todos.db \
      -p 3000:3000 \
      ghcr.io/username/todo:1.0
    ```

    Use a web browser to consume the app using the URL [localhost:3000](http://localhost:3000).

5. **Get some familiarity with the Kubernetes configuration for the application.**

    ```bash
    cd ../config
    cat deployment.yaml
    cat service.yaml
    ```

6. **Modify the Deployment definition to reference the image you have built, i.e.**

    ```yaml
    - image: ghcr.io/username/todo:1.0
    ```

7. **Depending on the OCI registry you have chosen to use for your image (and whether it's a public or private repo), you may need to create a secret for the credentials to authenticate. If so, create a Kubernetes secret containing your registry login credentials. If not, don't worry about the secret and be sure to amend the deployment definition to remove the `imagePullSecrets` section.**

    ```bash
    kubectl create secret generic ghcr-creds \
      --from-file=.dockerconfigjson=${HOME}/.docker/config.json \
      --type=kubernetes.io/dockerconfigjson
    ```

8. **Deploy the application to the cluster.**

    ```bash
    kubectl apply -f .
    ```

9. **Check the application is running as expected.** Make a note of the external IP address of the Service, and use this to consume the app in a web browser. Use `kubectl port-forward` if there is no external IP address assigned to the Service.

    ```bash
    kubectl get all
    ```

That's it! The 'todo' app should be running in the cluster using SQLite as the persistence layer.
