provider "vault" {}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_role" "example" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "webapp"
  bound_service_account_names      = ["vault-auth"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = ["svc-policy"]
  #audience                         = "vault"
}
