# Multi-Agent Solutions Platform

Production-oriented foundation for building and operating multiple governed agentic solutions using GitHub, AWS, Databricks, and Snowflake.

## Target architecture

- **GitHub**: source control, pull-request controls, OIDC-based CI/CD
- **AWS (`us-west-2`)**: agent runtime, eventing, identity, secrets, encryption, observability, and Bedrock
- **Databricks**: large-scale data/AI processing, embeddings, evaluation datasets, and AI experimentation
- **Snowflake**: governed enterprise data products, analytics, and agent operational reporting
- **Next.js + FastAPI**: solution experiences, control plane, orchestration API, and tool gateway

No long-lived cloud keys belong in GitHub. Deployment workflows should use short-lived identity federation; the current CI workflow runs validation and builds only.

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
## Dev infrastructure

Run from the repository root after configuring `infra/environments/dev/terraform.tfvars` and the dev backend:

```bash
AWS_PROFILE=awsconnect81 terraform -chdir=infra/environments/dev init
bash scripts/terraform-dev.sh plan -input=false -out=dev.tfplan
```

Review the plan, then apply it:

```bash
bash scripts/terraform-dev.sh apply dev.tfplan
```

Each helper invocation prompts for the Snowflake password. Type or paste it at
`Snowflake password:` and press Enter; characters are hidden. The helper passes
it to Terraform without saving it in the script. Plan and apply prompt separately.

The shared bucket layout and staged trust-policy bootstrap are proposed changes;
the current managed-storage module creates a dedicated bucket per environment.
See [the current storage implementation](infra/modules/databricks/storage.tf).

## Agent registry

The registry is implemented in [services/api/app/registry.py](services/api/app/registry.py).
The FastAPI service exposes `GET /v1/agents` and `POST /v1/agents` through
[services/api/app/main.py](services/api/app/main.py).
It is currently an in-memory placeholder: entries are lost on restart and are
not shared between API processes. Durable shared storage is not implemented yet.

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
