---
marp: true
theme: default
class: invert
paginate: true
--------------
<!-- slide: title -->

# No Backend? No Problem

## A Dropbox Clone with Cloudflare

**Piotr Niewęgłowski**

---

# Everyone Knows Cloudflare For...

* 🌐 DNS Management
* 🛡️ Bot Protection
* ⚡ CDN and Edge Caching
* 🚀 Performance Boosts

---

# ...But Few Know Cloudflare Offers

* 🧠 **Workers** (Serverless code at the edge)
* 📦 **R2** (Object storage without egress fees)
* 📃 **D1** (SQLite-based edge database)
* 📊 **KV Namespaces** (Key-Value store for global state)

---

# Let's Build Something Real

A **serverless Dropbox clone** using:

- Workers
- R2 (for files)
- D1 (for metadata)
- KV (for rate limits)

---

# Tools Used

🧰 **Terraform**

> For provisioning infrastructure

⚙️ **Wrangler**

> For local development, migrations, and deployment

---

# Part 1: Provision Infrastructure

🎯 What we provision:

- R2 bucket
- KV namespace
- D1 database
- Worker (placeholder) + subdomain

➡️ Let’s check provisioned objects and bindings!

---

# Part 2: Upload Files

POST `/files`

- Accept `multipart/form-data`
- Store file in R2
- Save metadata to D1

---

# Part 3: List Files

GET `/files`

- Read from D1
- Return file list as JSON

🧪 Handy for debugging or listing uploads

---

# Part 4: Download Files

GET `/files/:id`

- Lookup metadata in D1
- Stream file from R2
- Set `Content-Disposition`

---

# Part 5: Add Rate Limiting

📦 KV used to store IP-based upload counters

- 5 uploads/hour per IP
- Enforced in Worker
- Uses `CF-Connecting-IP`

🔒 Basic, but effective protection

---

# Use Cases in the Wild

### Real projects:

✅ Rate limiting for sensitive endpoints
✅ Protect against bot enumeration (return 404s)
✅ Serve static pages

---

# Other Use Cases You Might Consider

## Workers

💡 Custom APIs
💬 Middleware (auth, redirects, headers)
📊 A/B testing at the edge

## R2

📁 Media storage
🧪 CI artifacts / cache
📜 Static blog hosting

---

# Other Use Cases You Might Consider

## D1

🧾 Metadata
🔐 Auth sessions
⏱️ Small queues / logs

## KV

🚦 Feature flags
🧮 Caches / counters
🌍 Global config

---

# Try It Yourself

🧪 No Cloudflare egress fees
☁️ Truly serverless
🧰 Dev workflow feels familiar
💸 Free-tier friendly

---

# Questions? 🙋
