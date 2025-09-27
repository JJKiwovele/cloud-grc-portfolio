# Cloud GRC Portfolio — Healthcare PHI Focus

Hands-on labs demonstrating HIPAA-aligned controls in AWS for PHI:
encryption, least privilege, audit trails, detection, and response.

## Labs
- **[Lab 1 — S3 + SSE-KMS for PHI](lab1-s3-kms-encryption/README.md)**  
  Enforce default SSE-KMS, bucket policy (TLS + KMS), object metadata proof, CLI artifacts.

- **[Lab 2 — IAM Least Privilege: Dispatcher vs Paramedic](lab2-iam-least-privilege/README.md)**  
  Job-scoped roles, inline policies, allow/deny evidence via STS AssumeRole.

- **[Lab 3 — CloudTrail + Athena Audit Trail](lab3-cloudtrail-athena/README.md)**  
  Multi-region trail with S3 data events, Athena table, queries, CSV report.

## Reports
- `reports/sample-access-audit.csv` — Athena export of recent S3 Get/Put on PHI buckets.

## Environment
- Region: `us-east-2`
- Buckets: `cwh-sbx-raw-jj`, `cwh-sbx-processed-jj`, `cwh-sbx-logs-<acct>-us-east-2`
- KMS CMK: `alias/cwh-phi-key`

> All data is synthetic. No real PHI.
