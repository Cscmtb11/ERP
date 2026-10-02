-- Nexa ERP: GST / multi-currency compliance foundation
-- Safe for existing installations: creates new tables only.

CREATE TABLE IF NOT EXISTS invoice_tax_lines (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  invoice_id TEXT NOT NULL,
  taxable_value REAL NOT NULL DEFAULT 0,
  cgst_rate REAL NOT NULL DEFAULT 0,
  sgst_rate REAL NOT NULL DEFAULT 0,
  igst_rate REAL NOT NULL DEFAULT 0,
  cgst_amount REAL NOT NULL DEFAULT 0,
  sgst_amount REAL NOT NULL DEFAULT 0,
  igst_amount REAL NOT NULL DEFAULT 0,
  entered_tax_amount REAL NOT NULL DEFAULT 0,
  calculated_tax_amount REAL NOT NULL DEFAULT 0,
  tax_status TEXT NOT NULL DEFAULT 'pending',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_invoice_tax_lines_tenant
  ON invoice_tax_lines(tenant_id);
CREATE INDEX IF NOT EXISTS idx_invoice_tax_lines_invoice
  ON invoice_tax_lines(tenant_id, invoice_id);

CREATE TABLE IF NOT EXISTS gst_returns (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  return_type TEXT NOT NULL,
  gstin TEXT,
  financial_year TEXT NOT NULL,
  period TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  taxable_value REAL NOT NULL DEFAULT 0,
  cgst_amount REAL NOT NULL DEFAULT 0,
  sgst_amount REAL NOT NULL DEFAULT 0,
  igst_amount REAL NOT NULL DEFAULT 0,
  total_tax REAL NOT NULL DEFAULT 0,
  json_payload TEXT,
  generated_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_gst_returns_scope
  ON gst_returns(tenant_id, company_id, branch_id, financial_year, period);

CREATE TABLE IF NOT EXISTS gst_return_lines (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  return_id TEXT NOT NULL,
  invoice_id TEXT,
  invoice_no TEXT,
  invoice_date TEXT,
  gstin TEXT,
  taxable_value REAL NOT NULL DEFAULT 0,
  cgst_rate REAL NOT NULL DEFAULT 0,
  sgst_rate REAL NOT NULL DEFAULT 0,
  igst_rate REAL NOT NULL DEFAULT 0,
  cgst_amount REAL NOT NULL DEFAULT 0,
  sgst_amount REAL NOT NULL DEFAULT 0,
  igst_amount REAL NOT NULL DEFAULT 0,
  total_tax REAL NOT NULL DEFAULT 0,
  total_value REAL NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_gst_return_lines_scope
  ON gst_return_lines(tenant_id, return_id);

CREATE TABLE IF NOT EXISTS fx_rates (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  rate_date TEXT NOT NULL,
  base_currency TEXT NOT NULL DEFAULT 'INR',
  quote_currency TEXT NOT NULL,
  rate REAL NOT NULL,
  source TEXT,
  fetched_at INTEGER NOT NULL,
  UNIQUE(tenant_id, rate_date, base_currency, quote_currency, source)
);

CREATE INDEX IF NOT EXISTS idx_fx_rates_lookup
  ON fx_rates(tenant_id, rate_date, base_currency, quote_currency);

CREATE TABLE IF NOT EXISTS compliance_exports (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  export_type TEXT NOT NULL,
  period TEXT,
  file_name TEXT,
  payload TEXT NOT NULL,
  created_by TEXT,
  created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_compliance_exports_scope
  ON compliance_exports(tenant_id, company_id, branch_id, export_type, period);
