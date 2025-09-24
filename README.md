# Flink Table API Scalar UDF

This repository contains a Flink Table API Scalar User-Defined Function (UDF) that calculates custom tax rates based on location, along with automated CI/CD deployment to Confluent Cloud using Terraform.

## Overview

The `CustomTax` UDF is a scalar function that returns tax rates for different locations:
- **USA**: 10%
- **EU**: 5%
- **Canada**: 8%
- **UK**: 7%
- **Other/Unknown**: 0%

## Project Structure

```
├── src/main/java/com/example/flink/udf/
│   └── CustomTax.java              # The UDF implementation
├── src/test/java/com/example/flink/udf/
│   └── CustomTaxTest.java          # Unit tests
├── sql/
│   └── custom_tax_demo.sql         # Flink SQL demonstration
├── terraform/
│   ├── main.tf                     # Terraform configuration
│   └── terraform.tfvars.example   # Example variables file
├── .github/workflows/
│   └── ci-cd.yml                  # GitHub Actions CI/CD pipeline
└── pom.xml                        # Maven configuration
```

## Prerequisites

- Java 11 or higher
- Maven 3.6 or higher
- Terraform 1.6 or higher
- Confluent Cloud account with Flink compute pool
- GitHub repository with Actions enabled

## Local Development

### Building the Project

```bash
# Clone the repository
git clone <your-repo-url>
cd flink-udf

# Build the project
mvn clean package

# Run tests
mvn test
```

### Testing the UDF

The UDF includes comprehensive unit tests that verify:
- Correct tax rates for known locations
- Case-insensitive location matching
- Proper handling of null and unknown locations

```bash
mvn test
```

## Deployment

### GitHub Secrets Configuration

Before deploying, you need to configure the following GitHub Secrets in your repository:

#### Required Secrets:
- `CONFLUENT_CLOUD_API_KEY`: Your Confluent Cloud API key
- `CONFLUENT_CLOUD_API_SECRET`: Your Confluent Cloud API secret
- `FLINK_API_KEY`: Flink API key
- `FLINK_API_SECRET`: Flink API secret
- `ARTIFACT_API_KEY`: Artifact API key
- `ARTIFACT_API_SECRET`: Artifact API secret

#### Required Variables:
- `ORGANIZATION_ID`: Your Confluent Cloud organization ID
- `ENVIRONMENT_ID`: Your Confluent Cloud environment ID
- `COMPUTE_POOL_ID`: Your Flink compute pool ID
- `CLOUD_PROVIDER`: Cloud provider (default: "aws")
- `REGION`: Cloud region (default: "eu-west-1")
- `ARTIFACT_VERSION`: Version of the UDF artifact (default: "1.0.0")
- `CURRENT_CATALOG`: SQL catalog name (default: "mvisser")
- `CURRENT_DATABASE`: SQL database name (default: "standard_cluster")

### Setting up GitHub Secrets

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Add the required secrets and variables listed above

### Automated Deployment

The GitHub Actions workflow automatically:

1. **Builds** the UDF JAR artifact using Maven
2. **Tests** the code with unit tests
3. **Deploys** the UDF artifact using Terraform (`confluent_flink_artifact`)
4. **Creates** the Flink SQL statement using Terraform (`confluent_flink_statement`)

The deployment is triggered on pushes to the `main` branch.

**✅ Fully Automated via Terraform**: The UDF artifact and SQL statement are deployed using the Confluent Terraform provider resources.

### Manual Deployment

If you prefer to deploy manually:

```bash
# Navigate to terraform directory
cd terraform

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your actual values

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply deployment
terraform apply
```

## Usage in Flink SQL

Once deployed, you can use the UDF in your Flink SQL queries:

```sql
-- Register the UDF (if not already registered)
CREATE FUNCTION CustomTax AS 'com.example.flink.udf.CustomTax';

-- Use the UDF in queries
SELECT 
    location,
    amount,
    CustomTax(location) AS tax_rate,
    amount * CustomTax(location) / 100.0 AS tax_amount
FROM orders;
```

## Example SQL

The repository includes a complete example in `sql/custom_tax_demo.sql` that:

1. Creates sample source and sink tables
2. Demonstrates the UDF with various location inputs
3. Shows tax calculations for different regions

## Monitoring and Troubleshooting

### Terraform Outputs

After deployment, Terraform provides:
- `artifact_id`: The ID of the deployed Flink artifact
- `statement_id`: The ID of the deployed Flink statement

### Common Issues

1. **Authentication Errors**: Verify your API keys and secrets are correctly configured
2. **Resource Not Found**: Ensure your organization, environment, and compute pool IDs are correct
3. **Build Failures**: Check that Java 11 is available and Maven dependencies can be resolved

### Logs

- GitHub Actions logs are available in the Actions tab of your repository
- Terraform logs show deployment progress and any errors
- Flink statement logs are available in the Confluent Cloud console

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## References

- [Flink Table API Documentation](https://nightlies.apache.org/flink/flink-docs-master/docs/dev/table/)
- [Confluent Flink Documentation](https://docs.confluent.io/cloud/current/flink/index.html)
- [Confluent Terraform Provider](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs)
- [Original UDF Example](https://github.com/confluentinc/flink-table-api-java-examples/blob/master/src/main/java/io/confluent/flink/examples/table/Example_09_Functions.java#L99-L110)
