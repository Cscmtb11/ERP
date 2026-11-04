# Cloudflare configuration — erp.springnexa.in on Oracle Cloud

Cloudflare provides DNS, proxy, HTTPS edge, WAF and DDoS/security controls. ERPNext, MariaDB, Redis and all persistent business data run on the OCI VM. This is a direct Cloudflare-proxied origin architecture; no Cloudflare Worker or Tunnel is required.

## DNS

After the OCI VM has a public IPv4 address, create:

| Type | Name | Target | Proxy |
|---|---|---|---|
| A | erp | OCI VM public IPv4 | Proxied (orange cloud) |

Do not add an AAAA record unless IPv6 is configured and secured on the origin. Mail records (MX, SPF, DKIM, DMARC) are configured separately and remain DNS-only.

## TLS

1. Enable Cloudflare Universal SSL for the zone.
2. Create a Cloudflare Origin CA certificate for `erp.springnexa.in` (or use another publicly trusted origin certificate).
3. Install the certificate and private key on the OCI reverse proxy. Keep the private key only on the server with restrictive permissions.
4. In Cloudflare SSL/TLS → Overview, select **Full (strict)**.
5. Test HTTPS end-to-end before enabling Always Use HTTPS.

Do not use Flexible mode. Full (strict) requires the origin to serve a valid certificate matching the hostname and accept HTTPS on port 443.

## OCI and host firewall

- Initially allow TCP 80/443 for validation and web service.
- After proxy and certificate setup, restrict inbound origin web traffic to Cloudflare's current published IP ranges where practical.
- Keep SSH TCP 22 restricted to trusted administrator IPs and SSH keys.
- Never expose MariaDB 3306, Redis 6379, Frappe backend, worker, Docker API or internal service ports.
- Keep OCI security lists/NSGs and Ubuntu UFW rules consistent.

Cloudflare proxying does not replace origin firewalling; direct access to an exposed origin IP may bypass edge protections if the origin accepts arbitrary internet traffic.

## ERPNext-specific proxy behavior

- Preserve HTTP/1.1 websocket upgrade headers for Socket.IO/realtime.
- Set forwarded host and HTTPS scheme correctly.
- Bypass cache for all authenticated ERPNext desk, API, file and dynamic routes. Do not cache user-specific or authenticated responses.
- Check Cloudflare request-body/upload limits for the selected plan before uploading large attachments.
- Test login, desk assets, reports, print formats, file upload/download, realtime notifications and API integrations.
- Keep mail-related DNS records DNS-only.

## References

- Cloudflare proxy status: https://developers.cloudflare.com/dns/proxy-status/
- Cloudflare Full (strict): https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/full-strict/
- Cloudflare Origin CA: https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/
- Cloudflare IP ranges: https://www.cloudflare.com/ips/
