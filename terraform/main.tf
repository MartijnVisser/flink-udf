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

variable "current_catalog" {
  description = "Current catalog for Flink statements"
  type        = string
  default     = "mvisser"
}

variable "current_database" {
  description = "Current database for Flink statements"
  type        = string
  default     = "standard_cluster"
}

# Deploy the Flink UDF artifact
resource "confluent_flink_artifact" "custom_tax_udf" {
  environment {
    id = var.environment_id
  }
  region         = var.region
  cloud          = var.cloud_provider
  display_name   = "CustomTax UDF v${var.artifact_version}-${random_id.artifact_suffix.hex}"
  content_format = "JAR"
  artifact_file  = "${path.module}/../target/flink-udf-${var.artifact_version}.jar"

  lifecycle {
    prevent_destroy = true
  }
}

# Generate a random suffix for unique artifact naming
resource "random_id" "artifact_suffix" {
  byte_length = 4
}

# Create locals for artifact reference
locals {
  artifact_id = confluent_flink_artifact.custom_tax_udf.id
}

# Register the UDF function
resource "confluent_flink_statement" "create_function" {
  environment {
    id = var.environment_id
  }
  compute_pool {
    id = var.compute_pool_id
  }
  statement = "CREATE FUNCTION CustomTax AS 'com.example.flink.udf.CustomTax' USING JAR 'confluent-artifact://${local.artifact_id}';"
  properties = {
    "sql.current-catalog"  = var.current_catalog
    "sql.current-database" = var.current_database
  }

  depends_on = [confluent_flink_artifact.custom_tax_udf]

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
  statement = file("${path.module}/../sql/custom_tax_demo.sql")
  properties = {
    "sql.current-catalog"  = var.current_catalog
    "sql.current-database" = var.current_database
  }

  depends_on = [confluent_flink_statement.create_function]

  lifecycle {
    prevent_destroy = true
  }
}

# Output the artifact ID for reference
output "artifact_id" {
  description = "The ID of the deployed Flink artifact"
  value       = confluent_flink_artifact.custom_tax_udf.id
}

# Output the function creation statement ID
output "function_statement_id" {
  description = "The ID of the function creation statement"
  value       = confluent_flink_statement.create_function.id
}

# Output the demo statement ID for reference
output "demo_statement_id" {
  description = "The ID of the demo statement"
  value       = confluent_flink_statement.custom_tax_demo.id
}
