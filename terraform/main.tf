terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 2.0"
    }
  }
}

# Configure the Confluent Provider
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

# Variables for Confluent Cloud configuration
variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "organization_id" {
  description = "Confluent Cloud Organization ID"
  type        = string
}

variable "environment_id" {
  description = "Confluent Cloud Environment ID"
  type        = string
}

variable "compute_pool_id" {
  description = "Confluent Cloud Compute Pool ID"
  type        = string
}

variable "flink_api_key" {
  description = "Flink API Key"
  type        = string
  sensitive   = true
}

variable "flink_api_secret" {
  description = "Flink API Secret"
  type        = string
  sensitive   = true
}

variable "artifact_api_key" {
  description = "Artifact API Key"
  type        = string
  sensitive   = true
}

variable "artifact_api_secret" {
  description = "Artifact API Secret"
  type        = string
  sensitive   = true
}

variable "cloud_provider" {
  description = "Cloud provider (e.g., aws)"
  type        = string
  default     = "aws"
}

variable "region" {
  description = "Cloud region (e.g., eu-west-1)"
  type        = string
  default     = "eu-west-1"
}

variable "artifact_version" {
  description = "Version of the UDF artifact"
  type        = string
  default     = "1.0.0"
}

# Deploy the Flink UDF artifact
resource "confluent_flink_artifact" "custom_tax_udf" {
  cloud          = var.cloud_provider
  region         = var.region
  display_name   = "CustomTax UDF"
  content_format = "JAR"
  artifact_file  = "${path.module}/../target/flink-udf-${var.artifact_version}.jar"

  environment {
    id = var.environment_id
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Deploy the Flink SQL statement
resource "confluent_flink_statement" "custom_tax_demo" {
  environment {
    id = var.environment_id
  }
  compute_pool {
    id = var.compute_pool_id
  }
  name        = "CustomTax Demo Statement"
  description = "Flink SQL statement demonstrating the CustomTax UDF"
  statement   = file("${path.module}/../sql/custom_tax_demo.sql")

  depends_on = [confluent_flink_artifact.custom_tax_udf]
}

# Output the artifact ID for reference
output "artifact_id" {
  description = "The ID of the deployed Flink artifact"
  value       = confluent_flink_artifact.custom_tax_udf.id
}

# Output the statement ID for reference
output "statement_id" {
  description = "The ID of the deployed Flink statement"
  value       = confluent_flink_statement.custom_tax_demo.id
}
