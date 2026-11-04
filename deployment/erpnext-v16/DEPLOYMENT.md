# Deployment runbook — ERPNext v16 on Oracle Cloud Always Free

## 0. Important eligibility and cost checks

OCI Always Free compute is available only in the tenancy's home region. A1 capacity may be unavailable at a given time. The currently published Always Free A1 allowance is 2 OCPUs and 12 GB RAM total; combined boot/block-volume storage is 200 GB. The Console must explicitly label the VM shape and volumes **Always Free-eligible**.

The Free Tier sign-up may request a payment card for identity verification. Oracle documents a separate 30-day trial credit; do not confuse trial-credit resources with Always Free resources. Do not upgrade to Pay As You Go or create paid resources unless you knowingly approve that cost. Consider setting budgets/usage alerts and reviewing the estimate before provisioning.

## 1. Create OCI account and choose home region

1. Open https://www.oracle.com/cloud/free/ and create/sign in to the OCI account.
2. Choose an India home region offered during sign-up (Mumbai or Hyderabad if available to your account). The home region cannot simply be changed later; Always Free compute and block volumes must be created there.
3. Complete email/phone/payment-card verification if requested.
4. After sign-in, open the OCI Console and confirm the account/tenancy is active.

## 2. Create the Always Free Ampere VM

In OCI Console: Compute → Instances → Create instance.

Use:
- Name: `springnexa-erpnext-v16`
- Availability domain: any available domain in the home region
- Image: Ubuntu 24.04 LTS ARM64/AArch64 (choose an image compatible with A1 and confirm the resulting VM is Always Free-eligible)
- Shape: `VM.Standard.A1.Flex`
- OCPUs: `2`
- Memory: `12 GB`
- Boot volume: `100 GB` initially; this is part of the 200 GB combined Always Free storage allowance
- Networking: create/select a VCN and public subnet; assign a public IPv4 for the direct Cloudflare-proxied origin
- SSH: add your own public SSH key; keep the private key on your Windows PC and never upload it to GitHub or send it in chat

Before clicking Create, check the cost estimate and confirm the VM and boot volume show **Always Free-eligible**. Do not add paid block volumes, paid load balancers or other billable services. If A1 capacity is unavailable, retry later or try another availability domain in the same home region. Do not create a paid alternative by accident.

## 3. Configure OCI network security

Create/verify the subnet security list or network security group:
- TCP 22 (SSH): allow only your current trusted public IP where possible
- TCP 80 and 443: allow inbound for Cloudflare-origin web traffic and certificate setup
- Do not allow public inbound access to MariaDB 3306, Redis 6379, backend 8000, websocket/internal service ports or Docker APIs

After Cloudflare is working, restrict ports 80/443 to Cloudflare's published IPv4/IPv6 ranges where practical, while retaining a documented recovery path. Keep the OCI firewall and Ubuntu host firewall aligned. Never expose database/cache services.

## 4. Connect from Windows 11

Use Windows Terminal / PowerShell and your private SSH key:

```powershell
ssh -i "$env:USERPROFILE\.ssh\oci_erp_ed25519" ubuntu@YOUR_PUBLIC_IP
```

Replace the key path and IP with your actual values. The OCI Ubuntu image may use `ubuntu` as the default login; verify the image's documented username. Do not paste the private key into chat.

## 5. Prepare Ubuntu and Docker

On the VM:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y ca-certificates curl git gnupg ufw jq
```

Install Docker Engine and the Docker Compose v2 plugin using Docker's official Ubuntu ARM64 instructions:
https://docs.docker.com/engine/install/ubuntu/

Enable Docker and verify:
```bash
sudo systemctl enable --now docker
sudo docker version
sudo docker compose version
```

Create a non-root deployment user with sudo access if desired. Configure SSH key-only authentication only after verifying a second SSH session works. Enable unattended security updates.

## 6. Fetch deployment source

```bash
sudo git clone --branch deploy/erpnext-v16-cloudflare https://github.com/Cscmtb11/ERP.git /opt/springnexa-erp-config
sudo git clone https://github.com/frappe/frappe_docker.git /opt/frappe_docker
```

Review and pin a tested frappe_docker release/commit rather than blindly following future upstream changes. Copy the public app manifest:

```bash
sudo cp /opt/springnexa-erp-config/deployment/erpnext-v16/apps.json /opt/frappe_docker/apps.json
sudo chown -R "$USER":"$USER" /opt/frappe_docker
cd /opt/frappe_docker
```

## 7. Build or pull an ARM64 ERPNext v16 image

Use the official Frappe Docker production build instructions and ARM64 guide:
- https://frappe.github.io/frappe_docker/
- https://github.com/frappe/frappe_docker/blob/main/docs/01-getting-started/03-arm64.md

The deployment must use an image that explicitly supports `linux/arm64`. For a custom image, use Docker Buildx with the ARM64 platform and the `apps.json` manifest as a BuildKit secret, following the current official build instructions. Do not assume an x86_64 image will run natively on A1. Do not use the disposable `pwd.yml` demo for production.

## 8. Configure production Compose and secrets

Follow the current official Frappe Docker single-server production setup:
https://frappe.github.io/frappe_docker/02-setup/07-single-server-example.html

Configure:
- Site hostname: `erp.springnexa.in`
- ERPNext v16 app image for ARM64
- MariaDB and Redis internal-only
- frontend reverse proxy with HTTPS and websocket upgrade
- persistent database volume
- persistent Frappe sites volume (including private/public files)
- persistent logs volume
- restart policies and health checks

Create the real environment file only on the VM, not in Git:

```bash
sudo install -m 600 /dev/null /opt/frappe_docker/.env
sudo nano /opt/frappe_docker/.env
```

Generate strong unique database and Administrator passwords on the server/password manager. Do not put them in this repository, terminal command history, screenshots or chat. Run `docker compose config` and inspect the rendered services before starting; confirm internal ports are not published publicly.

## 9. Cloudflare DNS and TLS

Follow `CLOUDFLARE.md`:
- A record `erp` → OCI VM public IPv4, Proxied
- TLS mode Full (strict)
- install Cloudflare Origin CA or another valid origin certificate at the reverse proxy
- allow websocket upgrade and bypass caching for dynamic ERP routes

Cloudflare Workers and Tunnel are not used in this design.

## 10. Create site and install ERPNext

Only after the production Compose project is healthy, confirm the exact service/container names from the pinned official configuration. Use the official Frappe Docker site-creation procedure to create `erp.springnexa.in`, install ERPNext, and set a strong Administrator password. Confirm workers, scheduler and websocket are healthy.

## 11. Persistent data and backup policy

Live data stays on OCI persistent storage:
- MariaDB database files on a persistent volume
- Frappe sites volume including public/private attachments and site config
- logs as appropriate

Back up both the database and site files. Encrypt backups before copying them off the VM to an independent storage target (OCI Object Storage or Cloudflare R2). Check that the destination and storage tier are free/eligible before enabling; do not assume unlimited free backup storage. Keep a retention policy and test a restore to a separate staging site. A VM snapshot alone is not a complete application backup.

## 12. Acceptance checks before live use

- VM and all attached volumes are Always Free-eligible in OCI Console
- SSH access is key-based and restricted
- DNS resolves through Cloudflare; Full (strict) HTTPS works
- ERPNext desk, login/logout and password reset work
- background workers and scheduler execute
- realtime websocket connects
- representative file uploads/downloads and print formats work
- SMTP/email works if configured
- database and Redis ports are not public
- encrypted database + site-file backup completes and restore is tested
- storage, memory and CPU are monitored; keep free-tier resource limits in view

## Not yet performed

No OCI account, VM, network rule, DNS record, certificate, Docker stack or ERPNext site has been created by this runbook. Provisioning and account verification must be completed by the account owner. After the VM is created, share only its public IPv4 address and confirm Cloudflare zone access; never share passwords, private keys or API tokens.
