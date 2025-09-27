# Lab 3 — CloudTrail + Athena Audit Trail

**Goal**  
Enable CloudTrail S3 data events and query with Athena to prove “who accessed PHI, when, from where”.

**Evidence**
- `evidence/trail-event-selectors.json`
- `reports/sample-access-audit.csv` — CSV export of Athena query
- `evidence/athena-table.png` (screenshot of schema)
- `evidence/query-results.png` (screenshot of query results)

**Compliance**
- HIPAA 164.312(b) Audit Controls — maintain detailed logs of PHI access  
- SOC 2 CC7.2 — detect anomalous access attempts
