variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aws-iot-demo"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "temperature_threshold" {
  description = "Temperature threshold for alerts (in Celsius)"
  type        = string
  default     = "30"
}

variable "alert_email" {
  description = "Email for temperature alerts (leave empty to skip)"
  type        = string
  default     = ""
}
