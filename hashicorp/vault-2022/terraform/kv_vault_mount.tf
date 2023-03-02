resource "vault_mount" "kvv2" {
  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "example" {
  mount               = vault_mount.kvv2.path
  name                = "kv/dev/apps/service01"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      appkey   = "zsdkfjhj4534",
      apptoken = "zsdasdfaskfjhj4534"
    }
  )
}

data "vault_kv_secret_v2" "example" {
  mount = vault_mount.kvv2.path
  name  = vault_kv_secret_v2.example.name
}
