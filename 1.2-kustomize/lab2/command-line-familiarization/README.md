# PURPOSE

The purpose of this lab is to get familiar with the **Kustomize** CLI, using the standalone binary, as well as the version built into the Kubernetes client CLI, **kubectl**.

# REQUIREMENTS

This lab requires the installation of the **Kustomize standalone binary**. You can download it from [Kustomize releases](https://github.com/kubernetes-sigs/kustomize/releases). It also relies on **kubectl** being installed. Information for installing kubectl can be found [here](https://kubectl.docs.kubernetes.io/installation/kubectl/).

# STEPS

1. Get familiar with the Kustomize CLI by exploring its help options:

    ```bash
    kustomize --help
    kustomize build --help
    kustomize create --help
    kustomize edit --help
    ```

2. Find out which version of Kustomize you are using:

    ```bash
    kustomize version
    ```

3. Explore the Kustomize options built into kubectl:

    ```bash
    kubectl kustomize --help
    kubectl apply --help | grep -C1 kustomize
    ```

4. Find out which version of Kustomize is built into kubectl. Is it the same?

    ```bash
    kubectl version --short
    ```

Exploring the help for the CLI will give you a better overview of the options available. We'll use these commands as we progress through the exercise.
