PRAGMA foreign_keys=ON;

-- Company / branch / statutory masters
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
  active INTEGER NOT NULL DEFAULT 1,
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

-- User organization scope. Existing users are upgraded in-place by ADD COLUMN.
ALTER TABLE users ADD COLUMN company_id TEXT;
ALTER TABLE users ADD COLUMN branch_id TEXT;
ALTER TABLE users ADD COLUMN phone TEXT;
ALTER TABLE users ADD COLUMN job_title TEXT;
ALTER TABLE users ADD COLUMN last_login_at INTEGER;

CREATE TABLE IF NOT EXISTS user_company_access (
  user_id TEXT NOT NULL,
  company_id TEXT NOT NULL,
  PRIMARY KEY(user_id, company_id),
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY(company_id) REFERENCES companies(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_branch_access (
  user_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  PRIMARY KEY(user_id, branch_id),
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY(branch_id) REFERENCES branches(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_permissions (
  user_id TEXT NOT NULL,
  permission TEXT NOT NULL,
  allowed INTEGER NOT NULL DEFAULT 1,
  PRIMARY KEY(user_id, permission),
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_users_company ON users(company_id);
CREATE INDEX IF NOT EXISTS idx_users_branch ON users(branch_id);
CREATE INDEX IF NOT EXISTS idx_branches_company ON branches(company_id);
CREATE INDEX IF NOT EXISTS idx_registrations_company ON registrations(company_id);
CREATE INDEX IF NOT EXISTS idx_user_company_access_company ON user_company_access(company_id);
CREATE INDEX IF NOT EXISTS idx_user_branch_access_branch ON user_branch_access(branch_id);
