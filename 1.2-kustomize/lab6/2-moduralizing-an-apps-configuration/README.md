# PURPOSE

The purpose of this lab is to use Kustomize to render configuration for the example app using a number of Components containing modularized config. The build output will be compared with the saved build output from the previous exercise. Success will be defined as 'no difference', even though we've altered the setup considerably to define it as several reusable components.

# REQUIREMENTS

This lab simply requires an installation of the Kustomize standalone binary ([Kustomize Releases](https://github.com/kubernetes-sigs/kustomize/releases)). A comparison of the rendered configurations can be made manually in separate terminals, or you can use a diffing tool like 'delta' to make the comparison. To install delta for your OS, see [Delta Installation](https://dandavison.github.io/delta/installation).

# STEPS

1. Compare the overlays in the `before` and `after` directory structure in the config directory. Notice how the `qa` overlay Kustomization root is much simpler than before, but with references to Components. Inspect the different Component definitions to see how they differ from Kustomizations.

2. Perform a build of the 'qa' Kustomization in the `after` sub-directory, and save its output into a temporary directory for future comparison.

   ```sh
   cd config/after/overlays/qa
   QA_AFTER="$(mktemp -d -p /tmp)"
   kustomize build . -o $QA_AFTER
   ```

3. Make a comparison of the build from the previous exercise that is saved in the directory whose name is the value of the variable `QA_BEFORE`. Make sure that the comparison returns no differences. If it does return a diff, something has gone wrong!

   ```sh
   delta -s $QA_BEFORE $QA_AFTER
   ```

Despite the substantial changes between the configuration setup for the `qa` overlay, a build renders the same result. But, we've modularized the configuration to enable us to pick and choose which components of configuration we want to make use of in the overlay. Prefer to include the security context? Just remove the reference to its Component in the Kustomization!
