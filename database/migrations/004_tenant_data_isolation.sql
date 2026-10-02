-- Nexa ERP tenant data isolation layer
-- Run once after 003_saas_tenant_architecture.sql.
-- Existing records should be assigned to a tenant before non-admin users are enabled.

ALTER TABLE users ADD COLUMN tenant_id TEXT;
ALTER TABLE companies ADD COLUMN tenant_id TEXT;
ALTER TABLE branches ADD COLUMN tenant_id TEXT;
ALTER TABLE registrations ADD COLUMN tenant_id TEXT;
ALTER TABLE banks ADD COLUMN tenant_id TEXT;
ALTER TABLE customers ADD COLUMN tenant_id TEXT;
ALTER TABLE products ADD COLUMN tenant_id TEXT;
ALTER TABLE contracts ADD COLUMN tenant_id TEXT;
ALTER TABLE shipments ADD COLUMN tenant_id TEXT;
ALTER TABLE invoices ADD COLUMN tenant_id TEXT;

CREATE INDEX IF NOT EXISTS idx_users_tenant ON users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_companies_tenant ON companies(tenant_id);
CREATE INDEX IF NOT EXISTS idx_branches_tenant ON branches(tenant_id);
CREATE INDEX IF NOT EXISTS idx_registrations_tenant ON registrations(tenant_id);
CREATE INDEX IF NOT EXISTS idx_banks_tenant ON banks(tenant_id);
CREATE INDEX IF NOT EXISTS idx_customers_tenant ON customers(tenant_id);
CREATE INDEX IF NOT EXISTS idx_products_tenant ON products(tenant_id);
CREATE INDEX IF NOT EXISTS idx_contracts_tenant ON contracts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_shipments_tenant ON shipments(tenant_id);
CREATE INDEX IF NOT EXISTS idx_invoices_tenant ON invoices(tenant_id);
