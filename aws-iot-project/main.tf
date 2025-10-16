terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# IoT Thing
resource "aws_iot_thing" "temperature_sensor" {
  name = "${var.project_name}-temp-sensor"
}

# IoT Policy
resource "aws_iot_policy" "thing_policy" {
  name = "${var.project_name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:Connect",
          "iot:Publish",
          "iot:Subscribe",
          "iot:Receive"
        ]
        Resource = "*"
      }
    ]
  })
}

# IoT Certificate
resource "aws_iot_certificate" "cert" {
  active = true
}

# Attach policy to certificate
resource "aws_iot_policy_attachment" "att" {
  policy = aws_iot_policy.thing_policy.name
  target = aws_iot_certificate.cert.arn
}

# Attach certificate to thing
resource "aws_iot_thing_principal_attachment" "att" {
  principal = aws_iot_certificate.cert.arn
  thing     = aws_iot_thing.temperature_sensor.name
}

# DynamoDB Table for storing IoT data
resource "aws_dynamodb_table" "iot_data" {
  name           = "${var.project_name}-iot-data"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "deviceId"
  range_key      = "timestamp"

  attribute {
    name = "deviceId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  tags = {
    Name        = "${var.project_name}-iot-data"
    Environment = var.environment
  }
}

# Lambda execution role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda policy for DynamoDB and CloudWatch
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.iot_data.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# Lambda function
resource "aws_lambda_function" "process_iot_data" {
  filename      = "lambda_function.zip"
  function_name = "${var.project_name}-process-data"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.iot_data.name
      SNS_TOPIC_ARN  = aws_sns_topic.alerts.arn
      TEMP_THRESHOLD = var.temperature_threshold
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_policy
  ]
}

# Lambda permission for IoT
resource "aws_lambda_permission" "allow_iot" {
  statement_id  = "AllowExecutionFromIoT"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_iot_data.function_name
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_topic_rule.rule.arn
}

# IoT Topic Rule
resource "aws_iot_topic_rule" "rule" {
  name        = "${replace(var.project_name, "-", "_")}_rule"
  description = "Process IoT temperature data"
  enabled     = true
  sql         = "SELECT * FROM 'iot/temperature'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.process_iot_data.arn
  }
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-temperature-alerts"
}

# SNS Topic Subscription (optional - add your email)
resource "aws_sns_topic_subscription" "email_alert" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Get IoT endpoint
data "aws_iot_endpoint" "endpoint" {
  endpoint_type = "iot:Data-ATS"
}
