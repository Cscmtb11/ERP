-- Nexa ERP: transaction accounting and GST automation foundation
CREATE TABLE IF NOT EXISTS invoice_accounting_links (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  invoice_id TEXT NOT NULL,
  journal_entry_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  UNIQUE(tenant_id, invoice_id)
);
CREATE INDEX IF NOT EXISTS idx_invoice_accounting_links_scope ON invoice_accounting_links(tenant_id, invoice_id);

CREATE TABLE IF NOT EXISTS gst_transaction_lines (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  invoice_id TEXT NOT NULL,
  invoice_line_id TEXT,
  gstin TEXT,
  return_type TEXT NOT NULL DEFAULT 'GSTR1',
  financial_year TEXT,
  period TEXT,
  supply_type TEXT,
  place_of_supply TEXT,
  hsn_code TEXT,
  taxable_value REAL NOT NULL DEFAULT 0,
  cgst_rate REAL NOT NULL DEFAULT 0,
  sgst_rate REAL NOT NULL DEFAULT 0,
  igst_rate REAL NOT NULL DEFAULT 0,
  cgst_amount REAL NOT NULL DEFAULT 0,
  sgst_amount REAL NOT NULL DEFAULT 0,
  igst_amount REAL NOT NULL DEFAULT 0,
  total_tax REAL NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_gst_transaction_lines_scope ON gst_transaction_lines(tenant_id, company_id, branch_id, invoice_id, financial_year, period);

CREATE TABLE IF NOT EXISTS document_exports (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  document_type TEXT NOT NULL,
  reference_id TEXT NOT NULL,
  format TEXT NOT NULL,
  file_name TEXT NOT NULL,
  content TEXT,
  status TEXT NOT NULL DEFAULT 'generated',
  created_by TEXT,
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_document_exports_scope ON document_exports(tenant_id, company_id, branch_id, document_type, reference_id);
