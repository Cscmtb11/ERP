# SpringNexa ERPNext v16 — managed cloud deployment

Production target: https://erp.springnexa.in

Selected provider: DigitalOcean Droplet in Bangalore (BLR1), India. Initial plan: Basic 4 vCPU / 8 GiB RAM / 160 GiB SSD, listed at US$48/month before taxes and optional backups. This is cloud infrastructure hosting; the Droplet OS and ERPNext stack remain customer-administered unless a separate managed-operations service is contracted.

This deployment uses a Linux VPS/cloud VM for the complete ERPNext stack. Cloudflare provides authoritative DNS, proxied HTTPS, edge security and WAF. GitHub stores deployment code and configuration templates only.

**No live ERPNext data belongs in GitHub or Cloudflare Workers.** MariaDB data and Frappe site files remain on persistent storage attached to the cloud server. Cloudflare R2 may be used for encrypted off-site backups.

## Target architecture

Browser → Cloudflare DNS/proxy/WAF → HTTPS reverse proxy on managed VPS → Frappe frontend/backend → ERPNext v16.

The VPS runs the official Frappe Docker production stack:
- Frappe backend and Nginx frontend
- ERPNext v16 application image
- MariaDB database
- Redis cache and queue
- Socket.IO websocket service
- short/long background workers and scheduler
- persistent Docker volumes for database and site files

Cloudflare Worker is **not required** for this architecture. Do not deploy the earlier Worker proxy files for this managed-VPS design.

## Standard capacity profile

Initial sizing target (adjust after observing real usage):
- 4 vCPU
- 8 GB RAM
- 160 GB SSD/NVMe persistent disk
- Ubuntu 24.04 LTS x86_64
- Public static IPv4 preferred
- Provider snapshots plus independent encrypted database/site-file backups

This is a practical starting point for a small-to-medium deployment, not a guaranteed capacity for a specific number of concurrent users. Increase RAM/CPU/storage based on workload, attachments, reports and concurrent sessions.

## Repository contents

- `apps.json`: public app source manifest; ERPNext branch is `version-16`.
- `.env.example`: non-secret environment template.
- `DEPLOYMENT.md`: deployment runbook.
- `CLOUDFLARE.md`: DNS, TLS and security checklist.

Do not commit `.env`, passwords, API keys, database dumps, site backups, patient records, invoices, attachments, private keys, Cloudflare tokens or origin certificates. Keep production configuration on the VPS with restricted permissions.

## Deployment status

Repository preparation only. No cloud VM has been provisioned, no domain records have been changed, and no ERPNext site has been installed. The next required inputs are the VPS provider/instance and access method, plus confirmation that you control the Cloudflare zone for `springnexa.in`.

## Official references

- Frappe Docker: https://frappe.github.io/frappe_docker/
- Single-server production example: https://frappe.github.io/frappe_docker/02-setup/07-single-server-example.html
- Build setup and BuildKit secrets: https://frappe.github.io/frappe_docker/02-setup/02-build-setup.html
- Cloudflare proxied DNS: https://developers.cloudflare.com/dns/proxy-status/
- Cloudflare Full (strict): https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/full-strict/
