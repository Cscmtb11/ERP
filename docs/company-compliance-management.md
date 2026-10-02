# Company, Branch & Tax Compliance Management

The ERP now supports:

- Multiple legal companies
- Multiple branches per company
- Statutory registration records (GSTIN, PAN, TAN, IEC, CIN, MSME/UDYAM, FSSAI and other registrations)
- Registration status and expiry tracking
- GST working JSON generation
- ITR working JSON generation

## Apply the D1 migration

Run the contents of `database/migrations/2026_10_management_compliance.sql` in the Cloudflare D1 Console.

Or from a shell:

```bash
npx wrangler d1 execute nexa-erp --remote --file=database/migrations/2026_10_management_compliance.sql
```

## Compliance JSON

The ERP generates structured working JSON files for GST and ITR data. These are intentionally marked `portal_ready: false`: government filing schemas can change and the generated payload must be validated/transformed against the current official schema and filing utility before submission.

The ERP does not claim that generated JSON is an official filing or that tax calculations are automatically correct.
