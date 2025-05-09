variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "company" {
  description = "Company name"
  type        = string
  default     = "homework"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-example-terraform"
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}
