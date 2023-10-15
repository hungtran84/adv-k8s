# Sync Waves
An alternative way of deployment ordering: sync waves.

Sync phases can work in simple scenarios, but sometimes you want more flexibility on resource ordering. 

What happens for example if you want to run 3 jobs before the main sync phase, but you also want to order them among themselves? 

Using sync phases is not enough in that scenario, as by default ArgoCD will deploy every resource available in every individual phase.

Argo CD now has a newer method for resource ordering which is called sync waves.

`Sync waves `are a number you assign in each resource. By default is each resource is assigned to wave `0` but you can add both negative and positive values to different resources.

During a deployment ArgoCD will order all resources from the lowest number to the highest and then deploy them according to that order.

Here is an example of a sync wave annotation:

```yaml
annotations:
  argocd.argoproj.io/sync-wave: "-20"
```

## Using sync waves
You can see sync waves examples at https://github.com/hungtran84/argocd-example-app/tree/master/sync-hooks-waves/05-sync-waves

```yaml
db-upgrade is at -20
grafana-notify is at -10
deployment is at 0 (default)
namespace is at 0 (default)
service is at 0 (default)
cleanup is at 10
```

Let's see them in action

Create an Argo CD application (using the UI or CLI) with the following options
```yaml
application name : example05
project: default
SYNC POLICY: manual
repository URL: https://github.com/<your user>/argocd-example-app
path: ./sync-hooks-waves/05-sync-waves
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: example05
```

Click on the application card inside the Argo CD UI and sync the application manually. 


>Notice how Argo CD will deploy all resources according to the order outlined above. Not only we have defined 2 jobs (db-upgrade, grafana-notify) that need to happen before the sync phase, but we have also described that we want a specific order between them as well.

## Sync Waves with hooks
Choosing sync phases and waves
Using only sync waves is a good way to change the resource ordering but they still suffer from some limitations

Sync wave numbers are `"global"` for the whole application  

There are some known limitations with jobs and sync waves that might affect you  

You can combine sync waves and phases in a single application. If you do that then sync wave numbers are `"scoped"` to their respective sync phase making their management a bit easier.

Using sync waves and phases together
Our example application is at https://github.com/hungtran84/argocd-example-app/tree/master/sync-hooks-waves/06-waves-and-hooks

In your own GitHub fork, modify the manifests and add them to the following phase and wave

```yaml
cleanup.yml -> PostSync, wave 20
db-upgrade.yml -> PreSync, wave 10
disable-alerts.yml -> PreSync, wave 20
enable-alerts.yml -> PostSync, wave 30
grafana-notify.yml -> Sync, wave -10
slack-notify.yml -> PostSync, wave 30
smoke-test.yml -> PostSync, wave 10
```

Commit and push your changes.

Now let's see them in action

Create an Argo CD application (using the UI or CLI) with the following options

```yaml
application name : example06
project: default
SYNC POLICY: manual
repository URL: https://github.com/<your user>/argocd-example-app
path: ./sync-hooks-waves/06-waves-and-hooks
Cluster: https://kubernetes.default.svc (this is the same cluster where ArgoCD is installed)
Namespace: example06
```

Click on the application card inside the Argo CD UI and sync the application manually. Notice how Argo CD will deploy all resources according to the order outlined above.