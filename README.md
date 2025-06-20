# 📊 Dropbox Clone on Cloudflare Workers

This project is a simple Dropbox-style demo built on top of **Cloudflare Workers**, using:

* 🧱 **R2** for file storage
* 📃 **D1** for metadata (SQLite-based DB)
* 📊 **KV** for rate limiting
* 🌐 **Wrangler** for development & deployment
* 📒 **Terraform** to provision infrastructure

---

## ✨ Features

* `/files` (POST) — Uploads file to R2 and metadata to D1
* `/files` (GET) — Lists uploaded files from D1
* `/files/:id` (GET) — Downloads a file by ID
* Rate limiting based on IP using KV (max 5 uploads/hour)

---

## 🎓 Prerequisites

* Node.js (18+)
* Terraform (1.5+)
* `wrangler` (install via `npm i -g wrangler` or local `npx`)
* Cloudflare account
* Cloudflare R2 **must be activated manually** from the Cloudflare dashboard before provisioning
* A Cloudflare **API Token** with the following permissions:

  * Workers Scripts: Edit
  * Workers KV Storage: Edit
  * Workers R2 Storage: Edit
  * D1: Edit
  * Account Settings: Read

---

## 🏙️ Terraform: Provision Infrastructure

### 1. Set required environment variables

Set your Cloudflare credentials as env vars:

```bash
export TF_VAR_account_id="your-cloudflare-account-id"
export TF_VAR_cloudflare_api_token="your-api-token"
```

Or use a `.env` file and source it:

```bash
source .env
```

### 2. Run Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. What will be provisioned

* `dropbox-clone-bucket` (R2)
* `dropbox-clone-meta` (D1)
* `dropbox-clone-rate-limit` (KV)
* Reserved Worker named `dropbox-clone` with all bindings
* workers.dev subdomain activation

### 4. Terraform Outputs

After apply, you'll get:

* KV namespace ID
* D1 DB name
* R2 bucket name

> You’ll need these for your Wrangler config.

### 5. Cleaning up the infrastructure

After experimenting with the project, you may want to remove the provisioned infrastructure:

```bash
terraform destroy
```

⚠️ Warning: This action is irreversible. All data stored in D1 will be permanently lost.
If your R2 bucket is not empty, the operation will fail. In that case, everything except the R2 bucket will be destroyed.
---

## 💡 Wrangler: Worker Logic + Deployment

### 1. Setup Wrangler Config

In `worker/wrangler.jsonc`:

Replace the following placeholders:

```jsonc
"database_id": "REPLACE_WITH_YOUR_DB_ID"
"id": "REPLACE_WITH_YOUR_KV_NAMESPACE_ID"
```

> You can copy these from `terraform output` or from the Cloudflare dashboard.

### 2. Run D1 Migrations

#### 💼 Local:

```bash
npx wrangler d1 migrations apply dropbox-clone-meta --local
```

#### 🌐 Remote (Cloudflare):

```bash
npx wrangler d1 migrations apply dropbox-clone-meta --remote
```

> Your migration file is in `migrations/001_init.sql`.

### 3. Run Locally (for development)

```bash
npx wrangler dev
```

You can test against `http://localhost:8787/files`

### 4. Deploy to Cloudflare

```bash
npx wrangler deploy
```

After deployment, your Worker will be available at:

```
https://dropbox-clone.<your-subdomain>.workers.dev
```

---

## 🔧 Testing via Scripts

### 🛠️ Make scripts executable (one-time step)

Before running any scripts:

```bash
chmod +x scripts/*.sh
```

Scripts are in the `scripts/` folder:

You need to edit `scripts/config.sh` to change the root URL:

```bash
BASE_URL="https://dropbox-clone.<your-subdomain>.workers.dev"
```

> Replace `<your-subdomain>` with your actual Cloudflare Workers subdomain.  
> You can find it in the Cloudflare dashboard under:  
> **Workers → Settings → Subdomain**,  
> or retrieve it via `terraform output`.

### Upload file:

```bash
./scripts/upload.sh
```

Creates a test file and uploads it.

### List files:

```bash
./scripts/list.sh
```

Returns JSON list from D1.

### Download file:

```bash
./scripts/download.sh <file-id>
```

Saves file into `downloads/` folder.
