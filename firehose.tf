# 🔹 Firehose Delivery Stream Using Kinesis Data Stream
resource "aws_kinesis_firehose_delivery_stream" "myDeliveryStream" {
  depends_on  = [aws_opensearch_domain.my_opensearch, aws_kinesis_stream.my_stream]
  name        = "myDeliveryStream"
  destination = "opensearch"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.my_stream.arn  # 🔹 Use Kinesis as the source
    role_arn           = aws_iam_role.firehose_role.arn
  }

  opensearch_configuration {
    domain_arn         = aws_opensearch_domain.my_opensearch.arn
    role_arn           = aws_iam_role.firehose_role.arn
    index_name         = "trajectory"
    buffering_size     = 5  # Buffer: 5 MB
    buffering_interval = 60 # Buffer: 60 seconds
    s3_backup_mode     = "AllDocuments"

    s3_configuration {
      role_arn           = aws_iam_role.firehose_role.arn
      bucket_arn         = aws_s3_bucket.testtrajectory.arn
      prefix             = "firehose/failed/"
      buffering_size     = 5
      buffering_interval = 60
      compression_format = "GZIP"
    }

    # 🔹 Enable CloudWatch Logging
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_log_group.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_log_stream.name
    }
  }
}

# 🔹 IAM Role for Firehose to Read from Kinesis
resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# 🔹 Attach Necessary Permissions
resource "aws_iam_role_policy_attachment" "firehose_opensearch" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess"
}

resource "aws_iam_role_policy_attachment" "firehose_s3" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# 🔹 Additional Permissions for Firehose to Read from Kinesis
resource "aws_iam_role_policy" "firehose_kinesis_policy" {
  name   = "firehose_kinesis_access"
  role   = aws_iam_role.firehose_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords",
        "kinesis:ListShards"
      ],
      "Resource": "${aws_kinesis_stream.my_stream.arn}"
    }
  ]
}
EOF
}

# 🔹 Create CloudWatch Log Group for Firehose
resource "aws_cloudwatch_log_group" "firehose_log_group" {
  name = "/aws/firehose/myDeliveryStream"
  retention_in_days = 7  # 🔹 Keep logs for 7 days
}

# 🔹 Create CloudWatch Log Stream for Firehose
resource "aws_cloudwatch_log_stream" "firehose_log_stream" {
  name           = "firehose-error-logs"
  log_group_name = aws_cloudwatch_log_group.firehose_log_group.name
}

# 🔹 IAM Policy for Firehose to Write Logs to CloudWatch
resource "aws_iam_role_policy" "firehose_cloudwatch_policy" {
  name   = "firehose_cloudwatch_access"
  role   = aws_iam_role.firehose_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents",
        "logs:CreateLogStream",
        "logs:DescribeLogStreams"
      ],
      "Resource": "${aws_cloudwatch_log_group.firehose_log_group.arn}"
    }
  ]
}
EOF
}
