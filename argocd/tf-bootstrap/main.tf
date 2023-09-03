resource "random_password" "argo_admin_password" {
  length           = 32
  override_special = "!@#$%^&*"
  special          = true
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  chart            = "${path.module}/argo-cd-5.4.4.tgz"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false
  timeout          = 600

  values = [
    "${file("values.yaml")}"
  ]

  # set {
  #   name = "crds.keep"
  #   value = false
  # }

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(random_password.argo_admin_password.result, 10)
  }

  lifecycle {
    ignore_changes = [set_sensitive]
  }
}

