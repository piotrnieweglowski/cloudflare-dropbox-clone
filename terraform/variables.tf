variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token with permissions for Workers, KV, R2, and D1."
}

variable "account_id" {
  type        = string
  description = "Cloudflare Account ID."
}

variable "account_subdomain" {
  type        = string
  description = "Cloudflare Account Subdomain."
}