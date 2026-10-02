# Nexa ERP SaaS Architecture

## Tenant hierarchy

```text
SaaS Platform
  └── Tenant
       └── Company
            └── Branch
                 ├── Customers
                 ├── Suppliers
                 ├── Products
                 ├── Inventory
                 ├── Contracts
                 ├── Shipments
                 ├── Invoices
                 ├── Payments
                 ├── GST
                 └── Reports
```

## Identity and authorization

1. Cloudflare Secrets bootstrap the platform Admin.
2. D1 stores application users and sessions.
3. A user belongs to one or more tenants through `user_tenant_access`.
4. Company and branch access is granted through `user_company_access` and `user_branch_access`.
5. Roles map to permissions through `roles` and `role_permissions`.
6. The API must resolve tenant/company/branch scope from the authenticated session and access tables. Browser-supplied scope identifiers are untrusted input.

## Data isolation

D1 does not provide PostgreSQL-style native Row-Level Security. Nexa therefore uses shared tables with server-enforced tenant isolation. Every tenant-owned business query must include the authenticated tenant scope and, where applicable, company/branch scope.

The intended query shape is:

```sql
SELECT ...
FROM invoices
WHERE tenant_id = ?
  AND company_id = ?
  AND branch_id = ?;
```

The values must come from the authenticated server-side access context, never from arbitrary request parameters.

## Security boundary

```text
Request
  -> Session authentication
  -> User active check
  -> Tenant access check
  -> Company access check
  -> Branch access check
  -> Permission check
  -> Scoped SQL
  -> Audit event
```

This boundary applies to reads, writes, deletes, exports, PDFs, GST JSON, ITR JSON and reports.

## Migration policy

Do not recreate production tables to add architecture fields. Use additive D1 migrations and preserve existing records. Before applying an `ALTER TABLE ... ADD COLUMN`, inspect the current table with `PRAGMA table_info(<table>)`; SQLite/D1 does not support `ADD COLUMN IF NOT EXISTS` in the same way as some other SQL engines.

## Current D1

Binding: `DB`

Database: `nexa-erp`

Database ID: `d222d974-6417-46d6-b1a7-c9df31553dd9`
