variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "azureiotdemo"
  
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters and numbers."
  }
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
  description = "Email for temperature alerts"
  type        = string
  default     = ""
}
