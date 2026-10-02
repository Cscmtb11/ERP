-- Nexa ERP tenant data isolation layer
-- Run once after 003_saas_tenant_architecture.sql.
-- Existing records are assigned to the initial system tenant.

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

INSERT OR IGNORE INTO tenants(id,name,slug,status,plan,created_at,updated_at)
VALUES('system-tenant','Nexa ERP Default Tenant','system','active','standard',strftime('%s','now'),strftime('%s','now'));

UPDATE users SET tenant_id='system-tenant' WHERE tenant_id IS NULL;
UPDATE companies SET tenant_id='system-tenant' WHERE tenant_id IS NULL;
UPDATE branches SET tenant_id='system-tenant' WHERE tenant_id IS NULL;
UPDATE registrations SET tenant_id='system-tenant' WHERE tenant_id IS NULL;
UPDATE banks SET tenant_id='system-tenant' WHERE tenant_id IS NULL;
UPDATE customers SET tenant_id='system-tenant' WHERE tenant_id IS NULL;
UPDATE products SET tenant_id='system-tenant' WHERE tenant_id IS NULL;
UPDATE contracts SET tenant_id='system-tenant' WHERE tenant_id IS NULL;
UPDATE shipments SET tenant_id='system-tenant' WHERE tenant_id IS NULL;
UPDATE invoices SET tenant_id='system-tenant' WHERE tenant_id IS NULL;

INSERT OR IGNORE INTO user_tenant_access(user_id,tenant_id,is_default,created_at)
SELECT id,'system-tenant',1,strftime('%s','now') FROM users;

INSERT OR IGNORE INTO tenant_settings(tenant_id,base_currency,timezone,financial_year_start,created_at,updated_at)
VALUES('system-tenant','INR','Asia/Kolkata','04-01',strftime('%s','now'),strftime('%s','now'));
