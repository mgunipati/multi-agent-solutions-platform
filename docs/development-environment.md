# Basic development environment

This phase creates only the secure development foundation. It does not start Databricks compute, create a Snowflake warehouse, or deploy an application runtime.

## Required local tools (macOS)

```bash
brew install git terraform awscli databricks snowflake-cli
```

Run the repository preflight:

```bash
chmod +x scripts/preflight.sh
./scripts/preflight.sh
```

## AWS development identity

Use IAM Identity Center rather than the AWS root identity:

```bash
aws sso login --profile awsconnect81
export AWS_PROFILE=awsconnect81
export AWS_REGION=us-west-2
aws sts get-caller-identity --profile awsconnect81
```

The returned ARN should be an assumed SSO role, not `arn:aws:iam::<account>:root`.

## Databricks development identity

Authenticate to the existing workspace:

```bash
databricks auth login --host https://dbc-1a489bd9-4494.cloud.databricks.com --profile amazon-agents-account
export DATABRICKS_CONFIG_PROFILE=amazon-agents-account
databricks current-user me
```

The initial Terraform target is a development Unity Catalog catalog with `bronze`, `silver`, and `gold` schemas. Compute is intentionally excluded from the foundation.

## Snowflake development identity

Create a named Snowflake CLI connection using browser authentication for local development:

```bash
snow connection add
snow connection test --connection agentic-dev
snow sql --connection agentic-dev --query "select current_organization_name(), current_account_name(), current_user(), current_role();"
```

For CI/CD, replace interactive browser authentication with Workload Identity Federation or an approved service identity.

The initial Terraform target is a development database with `CURATED` and `AUDIT` schemas. A warehouse is intentionally excluded until workload size and auto-suspend settings are approved.

## Terraform state bootstrap

After the AWS SSO identity is verified:

```bash
cd infra/bootstrap
cp terraform.tfvars.example terraform.tfvars
```

Replace the state bucket placeholder with a globally unique name, then run:

```bash
terraform init
terraform plan
terraform apply
```

Then configure and plan development:

```bash
cd ../environments/dev
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.hcl
terraform plan -out=dev.tfplan
```

The development example enables Databricks and Snowflake now that all three connections pass. Stage and production remain disabled.

Before the development plan, supply Snowflake authentication only through the current terminal:

```bash
export SNOWFLAKE_ORGANIZATION_NAME=CNZYESW
export SNOWFLAKE_ACCOUNT_NAME=MF87278
export SNOWFLAKE_USER=AWSGOALS
export SNOWFLAKE_ROLE=ACCOUNTADMIN
read -s "SNOWFLAKE_PASSWORD?Snowflake password: "
echo
export SNOWFLAKE_PASSWORD
```

Review the saved plan before applying it. Immediately afterward, run `unset SNOWFLAKE_PASSWORD`.
