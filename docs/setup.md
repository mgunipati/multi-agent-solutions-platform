# Multi-agent platform account and deployment setup

## 1. Required administrative inputs

Collect these before provisioning:

- GitHub organization and repository owner/team names
- AWS account IDs for dev, stage, and prod (separate accounts preferred)
- AWS IAM Identity Center permission sets; do not operate the product from the root user
- Databricks workspace URL, account ID, Unity Catalog metastore, and platform service principal
- Snowflake organization name, account name, deployment role, and platform workload identity/service user
- Cost center, product owner, data owner, security owner, and data classification

## 2. Authenticate locally

Use named profiles and short-lived authentication:

```bash
aws configure sso --profile agentic-dev
aws sso login --profile agentic-dev
AWS_PROFILE=agentic-dev aws sts get-caller-identity

databricks auth login --host https://REPLACE.cloud.databricks.com
databricks auth profiles
```

For Snowflake, prefer Workload Identity Federation or key-pair authentication. Supply provider settings through supported `SNOWFLAKE_*` environment variables; never place private keys or passwords in `.tfvars`.

## 3. Bootstrap Terraform state

```bash
cd infra/bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Update each `backend.hcl` from its example, then initialize the environment:

```bash
cd ../environments/dev
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.hcl
terraform plan
```

The examples keep Databricks and Snowflake disabled. Enable them only after authentication and ownership are verified.

## 4. GitHub

Create the private repository, push this initial commit, then configure:

- environments: `dev`, `stage`, `prod`
- required reviewers for `prod`
- GitHub OIDC trust in each AWS account
- Databricks GitHub OIDC federation
- Snowflake Workload Identity Federation, where supported by your account policy
- secret scanning, push protection, Dependabot, and code scanning

## 5. Safe rollout order

1. GitHub repository and branch controls
2. AWS dev state and identity foundation
3. Databricks dev catalog and ingestion proof
4. Snowflake dev database and audit metrics proof
5. Control-plane/orchestrator/UI thin vertical slice
6. Repeat with approvals for stage, then prod
