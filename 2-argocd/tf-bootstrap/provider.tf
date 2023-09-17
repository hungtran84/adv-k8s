provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "rancher-desktop"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "rancher-desktop"
  }
  experiments {
    manifest = true
  }
}
