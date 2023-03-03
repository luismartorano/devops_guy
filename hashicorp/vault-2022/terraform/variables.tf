variable "kubernetes_host" {
  type        = string
  description = "URL for the Kubernetes API."
}

variable "kubernetes_ca_cert" {
  type        = string
  description = "Base64 encoded CA certificate of the cluster."
}

variable "token_reviewer_jwt" {
  type        = string
  description = "JWT token of the Vault Service Account."
}
