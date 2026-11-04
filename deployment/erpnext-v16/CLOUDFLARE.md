# Cloudflare configuration — erp.springnexa.in

Cloudflare is the DNS, HTTPS edge, WAF and DDoS/security layer. The ERPNext application, MariaDB, Redis and persistent site files run on the managed VPS.

## DNS

After the VPS public IPv4 is known, create:

| Type | Name | Target | Proxy |
|---|---|---|---|
| A | erp | VPS public IPv4 | Proxied (orange cloud) |

Do not create a Worker route or Worker custom domain for this host. The previous Worker reverse-proxy approach was for a different architecture and is not part of this managed VPS deployment.

Mail records (MX, SPF, DKIM, DMARC) should be configured separately if using a domain email service; mail-related records must remain DNS-only.

## SSL/TLS

1. Enable Cloudflare Universal SSL for the zone.
2. Set SSL/TLS encryption mode to **Full (strict)**.
3. Configure the VPS reverse proxy with a valid origin certificate (Cloudflare Origin CA or a publicly trusted certificate).
4. Enable Always Use HTTPS after HTTPS has been tested.
5. Do not use Flexible mode.

## Origin firewall

- Allow public web traffic on TCP 80/443 as required by the selected certificate/validation method.
- Restrict origin web traffic to Cloudflare IP ranges where operationally practical; keep the ranges updated from Cloudflare's published list.
- Keep SSH limited to trusted admin IPs and key authentication.
- Never expose MariaDB, Redis, Frappe backend or internal Docker service ports.
- Cloudflare proxying hides the origin IP from ordinary DNS answers but does not itself replace origin firewalling.

## ERPNext compatibility checks

- Preserve websocket upgrade support for Frappe realtime.
- Test large document uploads against the Cloudflare plan's request-body limits.
- Avoid caching authenticated ERPNext pages, API responses, desk assets with session-specific behavior, or POST requests. Use conservative cache settings; bypass cache for dynamic application routes.
- Confirm correct forwarded host/proto headers so ERPNext generates HTTPS URLs.
- Test login, desk, reports, file upload/download, print formats, realtime notifications and API integrations.

## Official references

- Proxy status: https://developers.cloudflare.com/dns/proxy-status/
- Proxy use cases: https://developers.cloudflare.com/dns/proxy-status/use-cases/
- Full (strict): https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/full-strict/
- Cloudflare IP ranges: https://www.cloudflare.com/ips/
