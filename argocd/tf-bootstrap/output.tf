output "argo_admin_password" {
  value     = nonsensitive(random_password.argo_admin_password.result)
}


