# SpringNexa ERPNext v16 — Oracle Cloud Always Free deployment

Production hostname: https://erp.springnexa.in

Target provider: Oracle Cloud Infrastructure (OCI) Always Free, using an Ampere A1 ARM64 VM in the tenancy's **home region**. Preferred regional choice for a new India-based tenancy: select the closest India region offered during sign-up (for example, Mumbai or Hyderabad) as the home region. OCI fixes the home region after tenancy creation; Always Free compute and block volumes must be provisioned there.

## Free-tier target (subject to account eligibility and capacity)

- Shape: VM.Standard.A1.Flex (ARM64)
- OCPUs: 2 total
- Memory: 12 GB total
- Boot volume: start with 100 GB (counts toward the 200 GB combined Always Free block-volume allowance)
- OS: Ubuntu 24.04 LTS ARM64, if shown as an eligible image
- Public IPv4: required for the direct Cloudflare-proxied origin design; review the OCI console estimate before creating it
- Region: tenancy home region in India, if available for the account

Oracle's published Always Free limits currently describe 1,500 OCPU-hours and 9,000 GB-hours per month for A1, equivalent to 2 OCPUs and 12 GB RAM for a full month, plus 200 GB combined boot/block-volume storage. The Console must label each selected resource **Always Free-eligible** before you create it. Capacity is not guaranteed. Never proceed if the estimate shows billable resources unless you intentionally approve a paid deployment.

This is a constrained single-server ERPNext deployment for evaluation and light use. It is not equivalent to a 4-vCPU/8-GB production VPS and is not a promise of production-grade availability. Heavy concurrent use, large attachments, reports or custom apps may require paid capacity.

## Architecture

Browser → Cloudflare DNS/proxy/WAF/HTTPS → OCI public IP → HTTPS reverse proxy → Frappe/ERPNext v16 containers → MariaDB + Redis + workers.

GitHub stores deployment scripts, app manifest and non-secret templates only. **Live ERP data never belongs in GitHub or Cloudflare Workers.** MariaDB data, Frappe site files, attachments and local backups remain on persistent OCI block storage. Encrypted off-site backups may be stored separately (for example, OCI Object Storage or Cloudflare R2); do not store backups in this Git repository.

Cloudflare Workers are not used. Cloudflare Tunnel is not required for this direct-origin setup.

## Runtime stack

Use the official Frappe Docker production configuration, not the disposable `pwd.yml` demo:
- Frappe backend and frontend/Nginx
- ERPNext v16 image built/pulled for `linux/arm64`
- MariaDB and Redis
- Socket.IO websocket service
- background workers and scheduler
- persistent database, sites, public/private files and logs volumes

The official Frappe Docker ARM64 guide documents the ARM64 platform setting. Pin the chosen image tags and frappe_docker commit for repeatable upgrades.

## Repository contents

- `apps.json`: ERPNext source manifest, branch `version-16`
- `.env.example`: non-secret environment template
- `DEPLOYMENT.md`: OCI provisioning and deployment runbook
- `CLOUDFLARE.md`: DNS, TLS and security checklist

Never commit `.env`, passwords, API keys, Cloudflare tokens, origin private keys/certificates, database dumps, site backups, patient/customer records, invoices or attachments.

## Current status

Only the repository deployment documentation/configuration is prepared. No OCI tenancy or VM has been created, no OCI resources have been provisioned, no DNS records have been changed, and ERPNext has not been installed. The user must create/confirm the OCI account and VM, then provide only the VM public IPv4 and confirm Cloudflare zone access. Never share an SSH private key, password or API secret in chat.

## Official references

- OCI Always Free resources: https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm
- OCI Free Tier: https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier.htm
- Frappe Docker: https://github.com/frappe/frappe_docker
- Frappe Docker ARM64 guide: https://github.com/frappe/frappe_docker/blob/main/docs/01-getting-started/03-arm64.md
- Cloudflare proxied DNS: https://developers.cloudflare.com/dns/proxy-status/
- Cloudflare Full (strict): https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/full-strict/
