# ERPNext v16 + Cloudflare on Windows 11

This folder contains deployment configuration for the existing Cscmtb11/ERP project. It does not copy or modify ERPNext source code. ERPNext is pulled from the official Frappe repository.

## Target architecture

- Windows 11 host
- WSL2 + Ubuntu 24.04
- Docker Desktop using the WSL2 Linux engine
- Official `frappe/frappe_docker` production Compose setup
- ERPNext and Frappe Framework `version-16`
- Cloudflare Tunnel on the Windows host, forwarding HTTPS traffic to the local ERPNext frontend
- Public hostname: `erp.springnexa.in`

> **Important:** A Windows 11 desktop is not equivalent to a managed production VPS. It must remain powered on, connected to the internet, and not enter sleep/hibernate. For business-critical use, migrate the same Docker deployment to an always-on Linux VPS later.

## Requirements

Recommended minimum for a small test / light-use installation: 4 CPU cores, 8 GB RAM (16 GB preferred), 100 GB free SSD, hardware virtualization enabled. More RAM and disk are needed as users, attachments, and background jobs grow.

Docker Desktop licensing may require a paid subscription for larger commercial enterprises or government entities. Check the current Docker terms before business use.

## 1. Prepare Windows 11

Open **PowerShell as Administrator**:

```powershell
wsl --install -d Ubuntu-24.04
wsl --update
```

Restart if Windows requests it. Open Ubuntu once and create your Linux username/password.

Install Docker Desktop from https://docs.docker.com/desktop/setup/install/windows-install/ . In Docker Desktop:
1. Settings → General → enable **Use the WSL 2 based engine**.
2. Settings → Resources → WSL Integration → enable Ubuntu-24.04.
3. Apply & Restart.
4. Confirm Docker Desktop is using **Linux containers**.

Install Git for Windows if it is not already installed: https://git-scm.com/download/win

## 2. Bootstrap official Frappe Docker source

Open the Ubuntu terminal (recommended) and run:

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/frappe/frappe_docker.git
cd frappe_docker
```

Copy the tracked app manifest from this repository into the Frappe Docker checkout. From Ubuntu, clone this project if needed:

```bash
git clone https://github.com/Cscmtb11/ERP.git
cp ERP/deployment/erpnext-v16/apps.json frappe_docker/apps.json
```

The manifest pins ERPNext to the requested `version-16` branch. The official Frappe Docker build documentation describes building a custom image from this manifest. Build and tag the image as `springnexa/erpnext:v16` using the official command documented at:
https://frappe.github.io/frappe_docker/02-setup/02-build-setup.html

Do not put GitHub tokens, passwords, or other secrets in `apps.json` or in Git.

## 3. Production Compose and site creation

Use the official production Compose method (base Compose file plus the MariaDB / Redis and other required overrides) from:
https://frappe.github.io/frappe_docker/02-setup/

Do **not** use `pwd.yml` for production. It is a disposable evaluation environment and is not a supported starting point for a persistent production deployment.

Configure the Compose stack to use the custom image `springnexa/erpnext:v16`, persistent Docker volumes, restart policies, and a frontend HTTP listener bound to loopback only (127.0.0.1). Do not publish MariaDB, Redis, or backend ports to the public network.

Create the site from inside the backend container using the official procedure:
```bash
docker compose exec backend bench new-site erp.springnexa.in --mariadb-user-host-login-scope='172.%.%.%'
docker compose exec backend bench --site erp.springnexa.in install-app erpnext
```

The exact Compose project name and override file names depend on the production method you select in the official guide. Use the same project name consistently for subsequent `docker compose` commands. Set a strong unique Administrator password and store it in a password manager.

## 4. Cloudflare Tunnel

1. Add `springnexa.in` to Cloudflare and confirm its nameservers are active at your registrar.
2. Install `cloudflared` on Windows using the official instructions: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/
3. In Cloudflare Zero Trust → Networks → Connectors → Cloudflare Tunnels, create a tunnel named `springnexa-erp`.
4. Install/run the tunnel connector on this Windows computer using the token/command Cloudflare displays. Treat that token as a password; never commit it to Git.
5. Add a Public Hostname:
   - Subdomain: `erp`
   - Domain: `springnexa.in`
   - Service type: HTTP
   - URL: `http://127.0.0.1:8080` (change this if your chosen Compose frontend port differs).
6. Enable Cloudflare Access and restrict the hostname to approved SpringNexa email identities before exposing business data.

Cloudflare Tunnel documentation: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/

## 5. Operations and safety

- Keep the Windows computer awake and Docker Desktop running. Configure Windows power settings to prevent sleep while plugged in.
- Back up the database **and** the site's private/public files. Keep encrypted copies outside this PC (for example, external disk plus a separate cloud backup).
- Test restoring backups before storing live company data.
- Apply ERPNext/Frappe updates only after reviewing version compatibility and taking a backup. Do not blindly pull `version-16` on a live installation.
- Do not expose ports 3306, 6379, backend, or SSH through the router.
- Use Cloudflare Access, strong passwords, MFA, least-privilege users, and regular security updates.
- For production, use a stable pinned image tag/commit after validation rather than automatically tracking a moving branch.

## Local validation

After the production stack is configured and running:
- Local check: `http://127.0.0.1:8080`
- Public check: `https://erp.springnexa.in`
- Confirm login, background jobs, email, file uploads, scheduled backups, and restore procedure.

## Important limitation

The files in this directory prepare the app selection and deployment runbook. They do not provision Windows, install Docker Desktop, create Cloudflare resources, or launch the ERP stack automatically. Those steps require local administrator access and your Cloudflare account.
