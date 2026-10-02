-- Nexa ERP: Financial reporting foundation
-- Creates reporting and reconciliation structures without modifying existing data.

CREATE TABLE IF NOT EXISTS account_periods (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT NOT NULL,
  financial_year TEXT NOT NULL,
  period_start TEXT NOT NULL,
  period_end TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(tenant_id, company_id, financial_year, period_start, period_end)
);

CREATE INDEX IF NOT EXISTS idx_account_periods_scope
  ON account_periods(tenant_id, company_id, status, period_start);

CREATE TABLE IF NOT EXISTS payment_allocations (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  payment_id TEXT NOT NULL,
  reference_type TEXT NOT NULL,
  reference_id TEXT NOT NULL,
  allocated_amount REAL NOT NULL DEFAULT 0,
  allocated_amount_in_inr REAL NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_payment_allocations_scope
  ON payment_allocations(tenant_id, company_id, payment_id, reference_type, reference_id);

CREATE TABLE IF NOT EXISTS reconciliation_runs (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  reconciliation_type TEXT NOT NULL,
  period_start TEXT,
  period_end TEXT,
  status TEXT NOT NULL DEFAULT 'draft',
  matched_count INTEGER NOT NULL DEFAULT 0,
  unmatched_count INTEGER NOT NULL DEFAULT 0,
  difference_amount REAL NOT NULL DEFAULT 0,
  created_by TEXT,
  created_at INTEGER NOT NULL,
  completed_at INTEGER
);

CREATE INDEX IF NOT EXISTS idx_reconciliation_runs_scope
  ON reconciliation_runs(tenant_id, company_id, branch_id, reconciliation_type, period_start, period_end);

CREATE TABLE IF NOT EXISTS reconciliation_items (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  reconciliation_id TEXT NOT NULL,
  source_type TEXT NOT NULL,
  source_id TEXT,
  external_reference TEXT,
  source_date TEXT,
  source_amount REAL NOT NULL DEFAULT 0,
  matched_amount REAL NOT NULL DEFAULT 0,
  difference_amount REAL NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'unmatched',
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_reconciliation_items_scope
  ON reconciliation_items(tenant_id, reconciliation_id, status);

CREATE TABLE IF NOT EXISTS report_snapshots (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  report_type TEXT NOT NULL,
  period_start TEXT,
  period_end TEXT,
  currency TEXT NOT NULL DEFAULT 'INR',
  payload_json TEXT NOT NULL,
  generated_by TEXT,
  created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_report_snapshots_scope
  ON report_snapshots(tenant_id, company_id, branch_id, report_type, period_start, period_end);
