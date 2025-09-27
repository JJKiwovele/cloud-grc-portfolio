#!/usr/bin/env bash
set -euo pipefail

REGION="us-east-2"
BUCKET_RAW="cwh-sbx-raw-jj"
BUCKET_PROCESSED="cwh-sbx-processed-jj"
KEY_ARN="arn:aws:kms:us-east-2:718962589155:key/ae064ab5-097d-4c61-b06a-98b0133315d0"  # <-- replace if needed

MYUSER_ARN="$(aws sts get-caller-identity --query Arn --output text)"

mkdir -p lab2-iam-least-privilege/evidence

cat > /tmp/trust.json <<EOF
{ "Version":"2012-10-17","Statement":[
  {"Effect":"Allow","Principal":{"AWS":"$MYUSER_ARN"},"Action":"sts:AssumeRole"}
]}
EOF

create_or_update_role () {
  local ROLE="$1"
  if aws iam get-role --role-name "$ROLE" >/dev/null 2>&1; then
    aws iam update-assume-role-policy --role-name "$ROLE" --policy-document file:///tmp/trust.json
  else
    aws iam create-role --role-name "$ROLE" --assume-role-policy-document file:///tmp/trust.json >/dev/null
  fi
}

create_or_update_role "CWH_Dispatcher"
create_or_update_role "CWH_Paramedic"

cat > /tmp/policy-dispatcher.json <<EOF
{ "Version":"2012-10-17","Statement":[
  {"Effect":"Allow","Action":["s3:ListBucket"],"Resource":["arn:aws:s3:::$BUCKET_RAW"],
   "Condition":{"StringLike":{"s3:prefix":["phi/intake/*"]}}},
  {"Effect":"Allow","Action":["s3:GetObject","s3:PutObject"],"Resource":["arn:aws:s3:::$BUCKET_RAW/phi/intake/*"]},
  {"Effect":"Allow","Action":["kms:Encrypt","kms:Decrypt","kms:GenerateDataKey*","kms:DescribeKey"],"Resource":["$KEY_ARN"]}
]}
EOF
aws iam put-role-policy --role-name CWH_Dispatcher --policy-name DispatcherS3KMSpolicy --policy-document file:///tmp/policy-dispatcher.json
cp /tmp/policy-dispatcher.json lab2-iam-least-privilege/evidence/dispatcher-policy.json

cat > /tmp/policy-paramedic.json <<EOF
{ "Version":"2012-10-17","Statement":[
  {"Effect":"Allow","Action":["s3:ListBucket"],"Resource":["arn:aws:s3:::$BUCKET_PROCESSED"],
   "Condition":{"StringLike":{"s3:prefix":["phi/redacted/*"]}}},
  {"Effect":"Allow","Action":["s3:GetObject"],"Resource":["arn:aws:s3:::$BUCKET_PROCESSED/phi/redacted/*"]},
  {"Effect":"Allow","Action":["kms:Decrypt","kms:DescribeKey"],"Resource":["$KEY_ARN"]}
]}
EOF
aws iam put-role-policy --role-name CWH_Paramedic --policy-name ParamedicS3KMSpolicy --policy-document file:///tmp/policy-paramedic.json
cp /tmp/policy-paramedic.json lab2-iam-least-privilege/evidence/paramedic-policy.json

echo "Done. Policies saved under lab2-iam-least-privilege/evidence/"
