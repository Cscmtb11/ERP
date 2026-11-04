# Deployment runbook — ERPNext v16 on managed VPS

## 1. Provision the server

Recommended provider: DigitalOcean, Bangalore datacenter `BLR1`.

Create an Ubuntu 24.04 LTS x86_64 Basic Droplet with:
- 4 vCPU, 8 GiB RAM, 160 GiB SSD (initial standard profile)
- Expected listed compute price: US$48/month before taxes and optional backups; verify the live checkout price before purchase
- Region slug: `blr1`
- Enable automatic backups if offered and budgeted; configure independent off-site database/site-file backups regardless

Official references: https://www.digitalocean.com/pricing/droplets and https://docs.digitalocean.com/platform/regional-availability/
- Static public IPv4
- Provider firewall and automatic security updates
- Separate persistent data volume if the provider supports it

Do not select Windows hosting. Do not use a serverless-only Workers plan as the ERPNext application host.

## 2. Secure the VPS

- Create a non-root sudo user and use SSH keys.
- Disable password-based SSH after confirming key access.
- Allow inbound TCP 22 only from your administrative IP where practical, and TCP 80/443 for web traffic.
- Do not expose MariaDB (3306), Redis (6379), Frappe backend, worker or websocket internal ports publicly.
- Install Docker Engine and Docker Compose v2 using Docker's official Ubuntu instructions.
- Configure a firewall and unattended security updates.

## 3. Fetch deployment source

On the VPS:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git ca-certificates curl
git clone https://github.com/Cscmtb11/ERP.git /opt/springnexa-erp-config
cd /opt/springnexa-erp-config/deployment/erpnext-v16
```

Clone the official Frappe Docker repository separately:

```bash
git clone https://github.com/frappe/frappe_docker.git /opt/frappe_docker
cd /opt/frappe_docker
cp /opt/springnexa-erp-config/deployment/erpnext-v16/apps.json ./apps.json
```

Review and pin the frappe_docker release/commit used for production rather than blindly following future upstream changes.

## 4. Build the ERPNext v16 image

Use Docker BuildKit/Buildx. The apps manifest is a build secret, not a build argument:

```bash
DOCKER_BUILDKIT=1 docker build \
  --no-cache \
  --build-arg=FRAPPE_PATH=https://github.com/frappe/frappe \
  --build-arg=FRAPPE_BRANCH=version-16 \
  --secret=id=apps_json,src=apps.json \
  --tag=springnexa/erpnext:v16 \
  --file=images/layered/Containerfile .
```

The official image build process uses the manifest to install ERPNext from its `version-16` branch. Do not place private Git credentials in build arguments or repository files.

## 5. Configure production Compose

Follow the official Frappe Docker **Single Server Setup** and **Single Server Example** for the exact current Compose files and environment variables:
https://frappe.github.io/frappe_docker/02-setup/07-single-server-example.html

Use the production multi-service setup, not `pwd.yml` (quick demo). Configure the stack to use `springnexa/erpnext:v16`, MariaDB and Redis. Set the public site hostname to `erp.springnexa.in`.

Requirements:
- MariaDB and Redis must have persistent volumes.
- Frappe sites volume must persist both public and private files.
- Configure restart policies and health checks.
- Do not publish internal database/cache/backend/worker ports to the public interface.
- Configure the public frontend/reverse proxy for HTTPS and websocket upgrade.
- Keep all production secrets in server-side environment files with mode 600, never in Git.

Before running `docker compose up -d`, inspect the fully rendered configuration with `docker compose config` and confirm no secret is being printed into CI logs.

## 6. Create the ERPNext site

After the official production stack is healthy, use the backend container and the documented site operations for that exact Compose project. The site name must be `erp.springnexa.in`. Create a strong Administrator password, install ERPNext, then verify scheduler and workers are running.

Do not run site-creation commands until the production Compose project name and backend service name have been confirmed from the selected official setup. Keep the Administrator password in a password manager.

## 7. Cloudflare

Follow `CLOUDFLARE.md`. Set Cloudflare SSL/TLS to Full (strict), proxy the web DNS record, and restrict origin access to Cloudflare IP ranges where compatible with provider firewall rules. Confirm websocket, uploads and downloads work through the proxy.

## 8. Backups and recovery

Back up BOTH:
1. MariaDB database (consistent database backup).
2. Frappe site files, including private/public files and site configuration needed for restore.

Store encrypted copies off the VPS (Cloudflare R2 is an optional destination). Keep provider snapshots as an additional recovery layer, not the only backup. Define retention, monitor backup success, and test restoration to a separate staging site before entering live business data.

## 9. Acceptance tests before production

- DNS resolves to Cloudflare and HTTPS certificate is valid.
- Login/logout and password reset work.
- ERPNext desk loads and assets load correctly.
- Background jobs and scheduler execute.
- Realtime notifications/websocket connect.
- Upload/download of representative documents works.
- Email delivery works (SMTP is outbound from the VPS; DNS mail records remain DNS-only).
- Backup completes and restore test succeeds.
- Firewall scan confirms database and Redis are not public.
- Cloudflare security events and VPS monitoring are visible.

## Not performed by this repository preparation

This runbook does not provision a VPS, change Cloudflare DNS, issue certificates, create credentials, start containers or install ERPNext. Those steps require access to the selected hosting provider and Cloudflare account.
