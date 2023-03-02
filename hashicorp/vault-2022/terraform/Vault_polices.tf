resource "vault_policy" "example" {
  name = "svc-policy"

  policy = <<EOT
path "kv/data/dev/apps/service01" {
  capabilities = ["read"]
}
EOT
}
