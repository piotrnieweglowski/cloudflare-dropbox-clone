terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_r2_bucket" "dropbox_clone" {
  account_id = var.account_id
  name       = "dropbox-clone-bucket"
}

resource "cloudflare_workers_kv_namespace" "dropbox_clone_rate_limit" {
  account_id = var.account_id
  title      = "dropbox-clone-rate-limit"
}

resource "cloudflare_d1_database" "dropbox_clone_meta" {
  account_id = var.account_id
  name       = "dropbox-clone-meta"
  read_replication = {
    mode = "disabled"
  }
}

resource "cloudflare_workers_script" "dropbox_clone" {
  account_id  = var.account_id
  script_name = "dropbox-clone"
  main_module = "worker.js"
  content     = file("worker.js")

  bindings = [
    {
      type = "d1"
      name = "DB"
      id   = cloudflare_d1_database.dropbox_clone_meta.id
    },
    {
      type         = "kv_namespace"
      name         = "RATE_LIMIT"
      namespace_id = cloudflare_workers_kv_namespace.dropbox_clone_rate_limit.id
    },
    {
      type        = "r2_bucket"
      name        = "FILES"
      bucket_name = cloudflare_r2_bucket.dropbox_clone.name
    },
    {
      type = "plain_text"
      name = "MAX_UPLOAD_SIZE"
      text = "10485760"
    }
  ]
}

resource "cloudflare_workers_script_subdomain" "dropbox_clone_workers_script_subdomain" {
  account_id       = var.account_id
  script_name      = "dropbox-clone"
  enabled          = true
  previews_enabled = true

  depends_on = [cloudflare_workers_script.dropbox_clone]
}

output "kv_namespace_id" {
  value = cloudflare_workers_kv_namespace.dropbox_clone_rate_limit.id
}

output "r2_bucket_name" {
  value = cloudflare_r2_bucket.dropbox_clone.name
}

output "d1_database_name" {
  value = cloudflare_d1_database.dropbox_clone_meta.name
}

output "worker_dev_url" {
  value = "https://${cloudflare_workers_script.dropbox_clone.script_name}.${var.account_subdomain}.workers.dev"
  description = "URL to access the deployed Worker via workers.dev"
}