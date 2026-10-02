-- Nexa ERP: Import / Export management foundation
-- Safe for existing installations: creates new tables only.

CREATE TABLE IF NOT EXISTS trade_partners (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  partner_type TEXT NOT NULL DEFAULT 'customer',
  legal_name TEXT NOT NULL,
  country_code TEXT,
  tax_id TEXT,
  registration_no TEXT,
  currency TEXT NOT NULL DEFAULT 'INR',
  payment_terms_days INTEGER NOT NULL DEFAULT 0,
  credit_limit REAL NOT NULL DEFAULT 0,
  address TEXT,
  contact_name TEXT,
  email TEXT,
  phone TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_trade_partners_scope
  ON trade_partners(tenant_id, company_id, branch_id, partner_type);

CREATE TABLE IF NOT EXISTS trade_orders (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  order_type TEXT NOT NULL,
  order_no TEXT NOT NULL,
  partner_id TEXT,
  order_date TEXT NOT NULL,
  currency TEXT NOT NULL DEFAULT 'INR',
  exchange_rate REAL NOT NULL DEFAULT 1,
  incoterm TEXT,
  origin_country TEXT,
  destination_country TEXT,
  status TEXT NOT NULL DEFAULT 'draft',
  subtotal REAL NOT NULL DEFAULT 0,
  freight REAL NOT NULL DEFAULT 0,
  insurance REAL NOT NULL DEFAULT 0,
  duty REAL NOT NULL DEFAULT 0,
  tax REAL NOT NULL DEFAULT 0,
  total REAL NOT NULL DEFAULT 0,
  notes TEXT,
  created_by TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(tenant_id, order_no)
);

CREATE INDEX IF NOT EXISTS idx_trade_orders_scope
  ON trade_orders(tenant_id, company_id, branch_id, order_type, order_date);

CREATE TABLE IF NOT EXISTS trade_order_lines (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  order_id TEXT NOT NULL,
  product_id TEXT,
  description TEXT NOT NULL,
  quantity REAL NOT NULL DEFAULT 0,
  unit TEXT,
  unit_price REAL NOT NULL DEFAULT 0,
  taxable_value REAL NOT NULL DEFAULT 0,
  tax_amount REAL NOT NULL DEFAULT 0,
  line_total REAL NOT NULL DEFAULT 0,
  hs_code TEXT,
  country_of_origin TEXT,
  created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_trade_order_lines_scope
  ON trade_order_lines(tenant_id, order_id);

CREATE TABLE IF NOT EXISTS shipments (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  trade_order_id TEXT,
  shipment_no TEXT NOT NULL,
  shipment_type TEXT NOT NULL,
  carrier TEXT,
  vessel_or_flight TEXT,
  container_no TEXT,
  bl_awb_no TEXT,
  port_of_loading TEXT,
  port_of_discharge TEXT,
  etd TEXT,
  eta TEXT,
  actual_departure TEXT,
  actual_arrival TEXT,
  status TEXT NOT NULL DEFAULT 'planned',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(tenant_id, shipment_no)
);

CREATE INDEX IF NOT EXISTS idx_shipments_scope
  ON shipments(tenant_id, company_id, branch_id, status);

CREATE TABLE IF NOT EXISTS shipment_documents (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  shipment_id TEXT NOT NULL,
  document_type TEXT NOT NULL,
  document_no TEXT,
  document_date TEXT,
  file_name TEXT,
  file_url TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_shipment_documents_scope
  ON shipment_documents(tenant_id, shipment_id, document_type);

CREATE TABLE IF NOT EXISTS landed_costs (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  trade_order_id TEXT,
  shipment_id TEXT,
  allocation_method TEXT NOT NULL DEFAULT 'value',
  currency TEXT NOT NULL DEFAULT 'INR',
  exchange_rate REAL NOT NULL DEFAULT 1,
  freight REAL NOT NULL DEFAULT 0,
  insurance REAL NOT NULL DEFAULT 0,
  customs_duty REAL NOT NULL DEFAULT 0,
  port_charges REAL NOT NULL DEFAULT 0,
  clearing_charges REAL NOT NULL DEFAULT 0,
  other_charges REAL NOT NULL DEFAULT 0,
  total_cost REAL NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_landed_costs_scope
  ON landed_costs(tenant_id, company_id, branch_id, trade_order_id, shipment_id);

CREATE TABLE IF NOT EXISTS landed_cost_allocations (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  landed_cost_id TEXT NOT NULL,
  product_id TEXT,
  quantity REAL NOT NULL DEFAULT 0,
  allocation_basis REAL NOT NULL DEFAULT 0,
  allocated_amount REAL NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_landed_cost_allocations_scope
  ON landed_cost_allocations(tenant_id, landed_cost_id);
