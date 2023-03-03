provider "vault" {}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend                = vault_auth_backend.kubernetes.path
  disable_iss_validation = "true" # k8s API checks it
  disable_local_ca_jwt   = "false"
  kubernetes_host        = var.kubernetes_host
  kubernetes_ca_cert     = base64decode(var.kubernetes_ca_cert)
  token_reviewer_jwt     = var.token_reviewer_jwt
  issuer                 = "api"

}

resource "vault_kubernetes_auth_backend_role" "example" {
  backend                          = vault_auth_backend.kubernetes.path
  alias_name_source                = "serviceaccount_uid"
  role_name                        = "webapp"
  bound_service_account_names      = ["vault-auth"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 250000
  token_policies                   = ["svc-policy"]
  #audience                         = "vault"
  token_type              = "default"
  token_no_default_policy = "false"
  token_explicit_max_ttl  = 0
  token_max_ttl           = 0
  token_num_uses          = 0
  token_period            = 0
}
