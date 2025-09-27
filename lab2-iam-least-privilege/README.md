# Lab 2 — IAM Least Privilege (Dispatcher vs Paramedic)

**Goal**  
Apply HIPAA “minimum necessary” by scoping roles to specific S3 prefixes:
- Dispatcher → RW: `s3://<raw>/phi/intake/`
- Paramedic → R: `s3://<processed>/phi/redacted/`

**Evidence**  
- Policies: `evidence/dispatcher-policy.json`, `evidence/paramedic-policy.json`
- Deny proof: `evidence/dispatcher-read-processed-deny.txt`, `evidence/paramedic-read-raw-deny.txt`
- Allow proof: `evidence/dispatcher-put-ok.json`, `evidence/paramedic-read-processed-ok.json`
