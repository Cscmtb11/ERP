-- Nexa ERP: Accounting core foundation
-- Safe for existing installations: creates new tables only.

CREATE TABLE IF NOT EXISTS chart_of_accounts (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  account_type TEXT NOT NULL,
  parent_id TEXT,
  opening_balance REAL NOT NULL DEFAULT 0,
  opening_balance_type TEXT NOT NULL DEFAULT 'debit',
  currency TEXT NOT NULL DEFAULT 'INR',
  active INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(tenant_id, company_id, code)
);

CREATE INDEX IF NOT EXISTS idx_coa_scope
  ON chart_of_accounts(tenant_id, company_id, account_type);

CREATE TABLE IF NOT EXISTS journal_entries (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  entry_no TEXT NOT NULL,
  entry_date TEXT NOT NULL,
  reference_type TEXT,
  reference_id TEXT,
  narration TEXT,
  currency TEXT NOT NULL DEFAULT 'INR',
  exchange_rate REAL NOT NULL DEFAULT 1,
  status TEXT NOT NULL DEFAULT 'posted',
  created_by TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(tenant_id, entry_no)
);

CREATE INDEX IF NOT EXISTS idx_journal_entries_scope
  ON journal_entries(tenant_id, company_id, branch_id, entry_date);

CREATE TABLE IF NOT EXISTS journal_lines (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  journal_entry_id TEXT NOT NULL,
  account_id TEXT NOT NULL,
  description TEXT,
  debit REAL NOT NULL DEFAULT 0,
  credit REAL NOT NULL DEFAULT 0,
  currency TEXT NOT NULL DEFAULT 'INR',
  exchange_rate REAL NOT NULL DEFAULT 1,
  foreign_amount REAL NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_journal_lines_scope
  ON journal_lines(tenant_id, journal_entry_id, account_id);

CREATE TABLE IF NOT EXISTS payments (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  payment_no TEXT NOT NULL,
  payment_date TEXT NOT NULL,
  payment_type TEXT NOT NULL,
  party_type TEXT,
  party_id TEXT,
  account_id TEXT,
  currency TEXT NOT NULL DEFAULT 'INR',
  exchange_rate REAL NOT NULL DEFAULT 1,
  amount REAL NOT NULL DEFAULT 0,
  amount_in_inr REAL NOT NULL DEFAULT 0,
  reference_no TEXT,
  status TEXT NOT NULL DEFAULT 'posted',
  notes TEXT,
  created_by TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(tenant_id, payment_no)
);

CREATE INDEX IF NOT EXISTS idx_payments_scope
  ON payments(tenant_id, company_id, branch_id, payment_date, payment_type);

CREATE TABLE IF NOT EXISTS bank_accounts (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  company_id TEXT,
  branch_id TEXT,
  bank_name TEXT NOT NULL,
  account_name TEXT NOT NULL,
  account_number_masked TEXT,
  ifsc TEXT,
  currency TEXT NOT NULL DEFAULT 'INR',
  ledger_account_id TEXT,
  opening_balance REAL NOT NULL DEFAULT 0,
  active INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_bank_accounts_scope
  ON bank_accounts(tenant_id, company_id, branch_id);
