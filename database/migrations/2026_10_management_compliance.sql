PRAGMA foreign_keys=ON;

CREATE TABLE IF NOT EXISTS companies (
  id TEXT PRIMARY KEY,
  legal_name TEXT NOT NULL,
  trade_name TEXT,
  pan TEXT,
  tan TEXT,
  cin TEXT,
  constitution TEXT,
  registered_address TEXT,
  email TEXT,
  phone TEXT,
  website TEXT,
  financial_year_start TEXT DEFAULT '04-01',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS branches (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  state_code TEXT,
  pincode TEXT,
  email TEXT,
  phone TEXT,
  active INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(company_id, code),
  FOREIGN KEY(company_id) REFERENCES companies(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS registrations (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL,
  branch_id TEXT,
  registration_type TEXT NOT NULL,
  registration_number TEXT NOT NULL,
  registration_date TEXT,
  expiry_date TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  issuing_authority TEXT,
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(company_id, registration_type, registration_number),
  FOREIGN KEY(company_id) REFERENCES companies(id) ON DELETE CASCADE,
  FOREIGN KEY(branch_id) REFERENCES branches(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS tax_periods (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL,
  financial_year TEXT NOT NULL,
  period TEXT NOT NULL,
  return_type TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  payload_json TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY(company_id) REFERENCES companies(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_branches_company ON branches(company_id);
CREATE INDEX IF NOT EXISTS idx_registrations_company ON registrations(company_id);
CREATE INDEX IF NOT EXISTS idx_tax_periods_company ON tax_periods(company_id);
