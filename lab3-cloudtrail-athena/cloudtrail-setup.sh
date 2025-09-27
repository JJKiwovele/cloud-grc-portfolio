#!/usr/bin/env bash
set -euo pipefail

REGION="us-east-2"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
TRAIL_NAME="cwh-audit-trail"
RAW_BUCKET="cwh-sbx-raw-jj"
PROC_BUCKET="cwh-sbx-processed-jj"
LOG_BUCKET="cwh-sbx-logs-${ACCOUNT_ID}-${REGION}"

mkdir -p lab3-cloudtrail-athena/evidence

# Create log bucket if missing
aws s3api create-bucket --bucket "$LOG_BUCKET" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION" || true

# Minimal CloudTrail bucket policy
cat > /tmp/ct-bucket-policy-min.json <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {"Sid":"AWSCloudTrailAclCheck20150319","Effect":"Allow","Principal":{"Service":"cloudtrail.amazonaws.com"},"Action":"s3:GetBucketAcl","Resource":"arn:aws:s3:::$LOG_BUCKET"},
    {"Sid":"AWSCloudTrailWrite20150319","Effect":"Allow","Principal":{"Service":"cloudtrail.amazonaws.com"},"Action":"s3:PutObject","Resource":"arn:aws:s3:::$LOG_BUCKET/AWSLogs/$ACCOUNT_ID/*","Condition":{"StringEquals":{"s3:x-amz-acl":"bucket-owner-full-control"}}}
  ]
}
EOF
aws s3api put-bucket-policy --bucket "$LOG_BUCKET" --policy file:///tmp/ct-bucket-policy-min.json

# Create trail (idempotent) and start logging
aws cloudtrail create-trail --name "$TRAIL_NAME" --s3-bucket-name "$LOG_BUCKET" --is-multi-region-trail || true
aws cloudtrail start-logging --name "$TRAIL_NAME"

# Enable S3 data events for PHI buckets
cat > /tmp/event-selectors.json <<EOF
[
  {"ReadWriteType":"All","IncludeManagementEvents":true,
   "DataResources":[{"Type":"AWS::S3::Object","Values":[
     "arn:aws:s3:::$RAW_BUCKET/",
     "arn:aws:s3:::$PROC_BUCKET/"
   ]}]}
]
EOF
aws cloudtrail put-event-selectors --trail-name "$TRAIL_NAME" --event-selectors file:///tmp/event-selectors.json

aws cloudtrail get-event-selectors --trail-name "$TRAIL_NAME" > lab3-cloudtrail-athena/evidence/trail-event-selectors.json

echo "Done. Trail '$TRAIL_NAME' logging to s3://$LOG_BUCKET . Event selectors saved under evidence/."
