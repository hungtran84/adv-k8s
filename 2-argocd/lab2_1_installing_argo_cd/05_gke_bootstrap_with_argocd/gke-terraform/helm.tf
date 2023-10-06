resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.46.7"
  wait             = true
  values           = [file("${path.root}/argocd/values-custom.yaml")]
  depends_on       = [module.gke]
}