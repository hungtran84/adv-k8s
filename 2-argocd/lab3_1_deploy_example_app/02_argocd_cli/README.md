# ArgoCD CLI
Apart from the UI, ArgoCD also has a CLI. We have installed already the cli for you and authenticated against the instance.

- Try the following commands  
```sh
argocd app list
NAME         CLUSTER                         NAMESPACE  PROJECT  STATUS  HEALTH   SYNCPOLICY  CONDITIONS  REPO                                                  PATH            TARGET
argocd/demo  https://kubernetes.default.svc  default    default  Synced  Healthy  <none>      <none>      https://github.com/hungtran84/argocd-example-app.git  helm-guestbook  HEAD

argocd app get demo
Name:               argocd/demo
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          default
URL:                http://argocd.yourcorp.com/applications/demo
Repo:               https://github.com/hungtran84/argocd-example-app.git
Target:             HEAD
Path:               helm-guestbook
SyncWindow:         Sync Allowed
Sync Policy:        <none>
Sync Status:        Synced to HEAD (d263a24)
Health Status:      Healthy

GROUP  KIND        NAMESPACE  NAME                 STATUS  HEALTH   HOOK  MESSAGE
       Service     default    demo-helm-guestbook  Synced  Healthy        service/demo-helm-guestbook created
apps   Deployment  default    demo-helm-guestbook  Synced  Healthy        deployment.apps/demo-helm-guestbook created

argocd app history demo
D  DATE                           REVISION
0   2023-10-08 00:25:06 +0700 +07  HEAD (d263a24)
```

- Let's delete the application and deploy it again but from the CLI this time.
  - First delete the app
    ```sh
    argocd app delete demo
    ```

  - Confirm the deletion by answering yes in the terminal. The application will disappear from the ArgoCD dashboard after some minutes.

  - Now deploy it again.
    ```sh
    argocd app create demo2 \
    --project default \
    --repo https://github.com/hungtran84/argocd-example-app.git \
    --path "helm-guestbook" \
    --dest-namespace default \
    --dest-server https://kubernetes.default.svc

    application 'demo2' created
    ```

  - The application will appear in the ArgoCD dashboard. Now sync it with
    ```sh
    argocd app sync demo2
    ```

- Cleanup application

```sh
argocd app delete demo2
```