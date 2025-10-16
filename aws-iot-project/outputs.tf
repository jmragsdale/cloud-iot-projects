output "iot_endpoint" {
  description = "AWS IoT endpoint"
  value       = data.aws_iot_endpoint.endpoint.endpoint_address
}

output "thing_name" {
  description = "IoT Thing name"
  value       = aws_iot_thing.temperature_sensor.name
}

output "certificate_arn" {
  description = "IoT Certificate ARN"
  value       = aws_iot_certificate.cert.arn
}

output "certificate_pem" {
  description = "IoT Certificate PEM"
  value       = aws_iot_certificate.cert.certificate_pem
  sensitive   = true
}

output "private_key" {
  description = "IoT Certificate Private Key"
  value       = aws_iot_certificate.cert.private_key
  sensitive   = true
}

output "dynamodb_table" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.iot_data.name
}

output "lambda_function" {
  description = "Lambda function name"
  value       = aws_lambda_function.process_iot_data.function_name
}

output "sns_topic" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.alerts.arn
}
