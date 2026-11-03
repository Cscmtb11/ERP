# ERPNext v16 + Cloudflare Workers on Windows 11

This deployment keeps ERPNext on Windows 11 and uses a Cloudflare Worker as the public reverse proxy for `erp.springnexa.in`. It does **not** use Cloudflare Tunnel.

## Architecture and networking requirement

Browser → Cloudflare Worker custom domain (`erp.springnexa.in`) → HTTPS origin (`origin-erp.springnexa.in`) → Windows 11 / WSL2 / Docker → ERPNext.

**Workers cannot reach localhost or private LAN addresses on your PC.** Without Tunnel or another outbound relay, Windows must expose an authenticated public HTTPS origin. This normally requires a public IP (CGNAT may prevent inbound access), router TCP 443 forwarding to Windows, a Windows/WSL reverse proxy, a valid TLS certificate, and an origin gate that validates a long random secret header added by the Worker.

If your ISP uses CGNAT or blocks inbound ports, Workers alone cannot create a route into your LAN. Use a VPS as the origin or reconsider Tunnel. Do not expose ERPNext directly without origin authentication.

## Components

- Windows 11 + WSL2 Ubuntu 24.04
- Docker Desktop with WSL2 integration
- Official `frappe/frappe_docker` production Compose setup
- ERPNext/Frappe `version-16`
- Worker custom domain: `erp.springnexa.in`
- DNS-only origin hostname: `origin-erp.springnexa.in` pointing to your public IP
- HTTPS reverse proxy on Windows/WSL, forwarding internally to ERPNext

## 1. Windows and Docker

PowerShell as Administrator:

```powershell
wsl --install -d Ubuntu-24.04
wsl --update
```

Restart if requested, open Ubuntu once, and create the Linux user.

Install Docker Desktop: https://docs.docker.com/desktop/setup/install/windows-install/
- Enable **Use the WSL 2 based engine**.
- Enable WSL Integration for Ubuntu-24.04.
- Apply & Restart.
- Confirm Linux containers are active.

## 2. Build ERPNext image

In Ubuntu:

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/frappe/frappe_docker.git
git clone https://github.com/Cscmtb11/ERP.git
cp ERP/deployment/erpnext-v16/apps.json frappe_docker/apps.json
cd frappe_docker
```

Build the custom image tagged `springnexa/erpnext:v16` using the official guide:
https://frappe.github.io/frappe_docker/02-setup/02-build-setup.html

Do not put credentials or tokens in Git.

## 3. Production Compose

Follow the official production deployment guide, not the disposable `pwd.yml` demo:
https://frappe.github.io/frappe_docker/02-setup/

Use persistent volumes and restart policies. Do not publish MariaDB, Redis, backend or worker ports. Bind the local frontend/reverse-proxy upstream to `127.0.0.1:8080` only.

Create the site and install ERPNext using the matching official production Compose project:

```bash
docker compose exec backend bench new-site erp.springnexa.in
docker compose exec backend bench --site erp.springnexa.in install-app erpnext
```

Set a strong unique Administrator password and store it in a password manager. Exact Compose overrides depend on the selected official production method.

## 4. Cloudflare DNS and Worker

1. Add `springnexa.in` to Cloudflare and ensure nameservers are active at the registrar.
2. Create DNS record `origin-erp` → your public IP. Keep it **DNS only** (grey cloud), as the Worker calls this origin directly.
3. Create a Worker and attach custom domain `erp.springnexa.in`.
4. Deploy `worker.js` from this folder using Wrangler or the Cloudflare dashboard.
5. Set Worker variable `ORIGIN_BASE_URL=https://origin-erp.springnexa.in`.
6. Add Worker secret `ORIGIN_AUTH_TOKEN` with a long random value. Never commit it.
7. Configure the origin reverse proxy to validate `X-SpringNexa-Origin-Token` against that same secret on every request, then strip the header before forwarding to ERPNext.
8. Enable Cloudflare WebSockets in the zone if needed. Test Frappe realtime, login, uploads and downloads.

Docs: https://developers.cloudflare.com/workers/configuration/routing/custom-domains/ and https://developers.cloudflare.com/workers/platform/limits/

## 5. Critical origin security

A Worker is a reverse proxy, not a private network connector. The origin has a public network path. Use HTTPS with a valid certificate and a reverse proxy that checks the secret token before forwarding to ERPNext. Do not expose Docker frontend, MariaDB, Redis, backend or SSH directly. Use a firewall, keep Windows and Docker patched, and consider a static IP. Never put the origin secret in browser JavaScript.

Do not assume Workers have a dedicated static egress IP. The shared-secret origin gate is required if the origin is internet reachable.

## 6. Backups and operations

- Keep Windows awake and Docker Desktop running.
- Back up database plus public/private site files, encrypted and off-device.
- Test a full restore before using live business records.
- Pin tested image versions/commits; do not blindly track a moving branch.
- Test login, background jobs, email, realtime events, uploads, downloads, backups and restore.
- For critical company data, prefer an always-on Linux VPS over a Windows desktop.

## Current status

The repository contains the app manifest and deployment guide. Worker source is a configurable reverse proxy, but production requires public origin connectivity, HTTPS, origin-side secret validation, Cloudflare custom domain configuration and end-to-end tests. Repository changes do not install software on Windows or create Cloudflare resources.
