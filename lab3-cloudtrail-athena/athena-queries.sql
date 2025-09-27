-- Create/use database (run one statement at a time in Athena)
-- CREATE DATABASE IF NOT EXISTS audit;
-- USE audit;

-- External table over CloudTrail logs in your log bucket
CREATE EXTERNAL TABLE IF NOT EXISTS cloudtrail_logs (
  eventVersion string,
  userIdentity struct<type:string,principalId:string,arn:string,accountId:string,accessKeyId:string,userName:string>,
  eventTime string,
  eventSource string,
  eventName string,
  awsRegion string,
  sourceIPAddress string,
  userAgent string,
  requestParameters string,
  responseElements string,
  additionalEventData string,
  requestId string,
  eventId string,
  readOnly string,
  resources array<struct<arn:string,accountId:string,type:string>>,
  eventType string
)
PARTITIONED BY (region string, year string, month string, day string)
ROW FORMAT SERDE 'com.amazon.emr.hive.serde.CloudTrailSerde'
STORED AS INPUTFORMAT 'com.amazon.emr.cloudtrail.CloudTrailInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://cwh-sbx-logs-718962589155-us-east-2/AWSLogs/718962589155/CloudTrail/'
TBLPROPERTIES ('classification'='cloudtrail');

-- Discover partitions
-- MSCK REPAIR TABLE cloudtrail_logs;

-- Recent S3 GET/PUT against PHI buckets
SELECT userIdentity.arn, eventName, requestParameters, sourceIPAddress, eventTime
FROM cloudtrail_logs
WHERE eventSource='s3.amazonaws.com'
  AND eventName IN ('GetObject','PutObject')
ORDER BY from_iso8601_timestamp(eventTime) DESC
LIMIT 100;

-- Denied attempts (if any)
SELECT userIdentity.arn, eventName, errorCode, requestParameters, eventTime
FROM cloudtrail_logs
WHERE eventSource='s3.amazonaws.com'
  AND errorCode IS NOT NULL
ORDER BY from_iso8601_timestamp(eventTime) DESC
LIMIT 100;
