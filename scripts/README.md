# Cloudflare production setup

This ERP uses Cloudflare Workers for the API/static app, D1 for users and trade records, and Worker Secrets for the bootstrap administrator credentials. Cloudflare recommends storing sensitive values with `wrangler secret put`, not in source or Wrangler vars.

## 1. Create D1

```bash
npx wrangler d1 create nexa-erp --remote --update-config --binding DB
```

Copy the generated D1 binding into `wrangler.toml` if Wrangler did not add it automatically:

```toml
[[d1_databases]]
binding = "DB"
database_name = "nexa-erp"
database_id = "YOUR_D1_DATABASE_ID"
```

Apply the schema:

```bash
npx wrangler d1 execute nexa-erp --remote --file=database/schema/cloudflare_d1.sql
```

## 2. Generate the bootstrap admin password hash

The Worker accepts a PBKDF2-SHA-256 value in this format:

`pbkdf2$210000$<salt>$<hash>`

Use a local secret/password tool or Node Web Crypto to generate it. Never commit the password or hash to Git.

## 3. Set Cloudflare Worker Secrets

```bash
npx wrangler secret put ADMIN_EMAIL
npx wrangler secret put ADMIN_PASSWORD_HASH
```

The first secret is the only bootstrap administrator email. The second is the PBKDF2 password hash.

## 4. Deploy

```bash
npx wrangler deploy
```

## 5. First login

Use the bootstrap `ADMIN_EMAIL` and its password. The administrator can then create additional ERP users from **Users & Access** with roles:

- `admin`
- `manager`
- `operator`
- `viewer`

Passwords created inside the ERP are hashed with PBKDF2-SHA-256 (210,000 iterations) before being stored in D1.

## Security model

- Passwords never reach the browser database or Git repository.
- Sessions use random bearer tokens stored only as SHA-256 hashes in D1 and an HttpOnly/Secure/SameSite cookie.
- Mutating API requests require same-origin requests.
- Admin-only user provisioning is enforced server-side.
- Exchange rates are fetched server-side and cached for five minutes.
