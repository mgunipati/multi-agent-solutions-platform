# Databricks managed storage

The catalog API needs an explicit managed location when the metastore has no
storage root. This foundation supplies that location without changing the shared
metastore. Enable it separately in each environment.

## Configuration

Set these values in the environment's untracked `terraform.tfvars`:

```hcl
enable_databricks                 = true
databricks_create_managed_storage = true
```

Leave `databricks_catalog_storage_root` unset/null. To reuse an existing authorized
location instead, set that path and leave `databricks_create_managed_storage=false`.
The two modes are mutually exclusive. Keep these settings on subsequent plans:
turning them off after deployment can propose deleting the foundation.

The Databricks provider must authenticate to a Unity Catalog-enabled **workspace**
in the same region as the AWS provider. The deployment identity needs permission
to create storage credentials, external locations, and catalogs, and to transfer
catalog ownership to `databricks_catalog_owner`. The configured profile name alone
does not establish whether its host is a workspace or the account console.

## Resources and bootstrap order

The shared Databricks module creates a dedicated bucket for each enabled environment,
with public access blocked, ACLs disabled, versioning, TLS enforcement, and SSE-KMS
using that environment's existing application key. The IAM policy is restricted
to this bucket, the encryption key, and role self-assumption.

The storage credential initially references a constructed future role ARN with
credential validation deferred. Its returned external ID and Unity Catalog IAM
principal feed the role trust policy, avoiding a circular dependency. Once the
role, permissions, and bucket controls exist, external-location creation validates
access. Validation is **not** disabled on the external location. The catalog uses
`s3://<generated-bucket>/managed/catalog`; bronze, silver, and gold inherit it.
The credential and external location are isolated to the creating workspace.

If AWS IAM propagation delays cause the first external-location validation to fail,
wait for propagation and create a fresh plan against the existing state. Do not
disable location validation or delete Terraform state.

## Dev plan and apply

From the repository root, using the existing AWS and Databricks profiles:

```bash
bash scripts/terraform-dev.sh plan -out=dev.tfplan
```

Review the complete plan, including AWS and Snowflake. Then:

```bash
bash scripts/terraform-dev.sh apply dev.tfplan
```

The helper prompts for the Snowflake password separately for each command and
passes it to Terraform without saving it. `DATABRICKS_CONFIG_PROFILE` defaults to
`amazon-agents-account` and can be overridden. The helper always targets dev.
Do not disable Snowflake to test Databricks: existing Snowflake resources would
then be scheduled for destruction in a full plan.

After apply, run a full plan again and confirm no changes. Verify the external
location in Catalog Explorer and the catalog's managed location. Successful plans
alone do not verify S3 access: the external-location check happens during apply.

Stage/prod use the same module inputs, but require their own backend configuration,
workspace credentials, and plan review. Do not reuse dev state or its saved plan.
All three environment plans must be reviewed before starting the subsequent
repository, registry, control-plane, model-access, service, CI/CD, and first-agent work.

## Verification and operations

Run `terraform init -backend=false` and `terraform test` in
`infra/modules/databricks` for mock-provider tests of the bootstrap dependency
graph, existing-storage mode, conflicting inputs, and missing encryption key.

Versioning retains deleted and overwritten objects, adding storage charges. S3
requests and KMS requests also incur usage charges; bucket keys are enabled to
reduce KMS request volume. No compute or vector-search endpoint is provisioned by
this change. Define retention for noncurrent versions before substantial ingestion.
Do not apply generic expiration rules to active managed-table objects.

For production observability, enable S3 server access logging to a separate
encrypted log bucket, CloudTrail S3 data events, and CloudWatch request metrics
and alarms. These are recommended follow-up controls and are not provisioned here;
their logging, storage, and metric usage can add cost.

## References

- [Databricks S3 external locations](https://docs.databricks.com/aws/en/connect/unity-catalog/cloud-storage/s3/s3-external-location-manual)
- [Provider Unity Catalog bootstrap example](https://github.com/databricks/terraform-provider-databricks/blob/v1.131.0/docs/guides/unity-catalog.md)
- [AWS S3 security practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
- [S3 pricing](https://aws.amazon.com/s3/pricing/)
