# Multi-Agent Solutions Platform

Production-oriented foundation for building and operating multiple governed agentic solutions using GitHub, AWS, Databricks, and Snowflake.

## Architecture

- **GitHub**: source control, pull-request controls, OIDC-based CI/CD
- **AWS (`us-west-2`)**: agent runtime, eventing, identity, secrets, encryption, observability, and Bedrock
- **Databricks**: large-scale data/AI processing, embeddings, evaluation datasets, and AI experimentation
- **Snowflake**: governed enterprise data products, analytics, and agent operational reporting
- **Next.js + FastAPI**: solution experiences, control plane, orchestration API, and tool gateway

No long-lived cloud keys belong in GitHub. Workflows assume short-lived identity federation.

## Repository layout

```text
apps/web                  Next.js user interface
services/api              FastAPI service
infra/bootstrap           Terraform state bootstrap
infra/modules             Reusable provider modules
infra/environments        dev, stage, and prod compositions
docs                      Architecture and setup guidance
```

## Start here

1. Review [docs/architecture.md](docs/architecture.md).
2. Build the local foundation using [docs/development-environment.md](docs/development-environment.md).
3. Complete the platform prerequisites in [docs/setup.md](docs/setup.md).
4. Copy the relevant `terraform.tfvars.example` to an untracked `terraform.tfvars`.
5. Bootstrap remote Terraform state before applying an environment.
6. Configure GitHub environments and OIDC roles; never commit credentials.

For the Databricks catalog storage prerequisite, follow [Databricks managed storage](docs/databricks-managed-storage.md).

## Local API

```bash
cd services/api
python -m venv .venv
source .venv/bin/activate
pip install -e '.[dev]'
uvicorn app.main:app --reload
```

## Local web application

```bash
cd apps/web
npm install
npm run dev
```
