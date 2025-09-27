# Lab 1 — Secure PHI Storage in S3 with SSE-KMS

**Goal**  
Enforce default **SSE-KMS** on PHI buckets using a customer-managed key (`alias/cwh-phi-key`). Upload synthetic PHI (`patients.csv`) and prove enforcement:
- TLS-only (deny if `aws:SecureTransport=false`)
- KMS-only uploads (deny unencrypted or wrong key)
- Object metadata shows `aws:kms` with the correct CMK

**What I built**  
- S3 buckets: `cwh-sbx-raw-jj`, `cwh-sbx-processed-jj`
- KMS CMK: `alias/cwh-phi-key` (customer-managed)

**Evidence (screenshots)**  
- `evidence/s3-default-encryption.png` — bucket default SSE-KMS  
- `evidence/s3-bucket-policy.png` — policy enforces TLS + KMS  
- `evidence/object-metadata-kms.png` — object shows `aws:kms`  
- `evidence/kms-key-details.png` — CMK details

**Evidence (CLI artifacts)**  
- `evidence/get-bucket-encryption.json`  
- `evidence/bucket-policy.json`  
- `evidence/deny-unencrypted.txt`  
- `evidence/ok-encrypted.json`  
- `evidence/head-object-encrypted.json`

**Compliance mapping**  
- HIPAA 164.312 (a,c) Access/Integrity → least privilege + encryption  
- SOC 2 CC6.*, CC7.2 → encryption in transit/at rest + auditability

**Notes**  
`patients-generator.py` creates 100 fake rows (no real PHI).
