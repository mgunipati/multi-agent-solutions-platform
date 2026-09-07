#!/usr/bin/env bash
# Prompt on every invocation so plan and apply both receive fresh credentials.
set +x
set -euo pipefail

case "${1:-}" in
  plan|apply) ;;
  *)
    printf 'Usage: bash scripts/terraform-dev.sh {plan|apply} [terraform arguments...]\n' >&2
    exit 2
    ;;
esac

task_repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

export AWS_PROFILE="${AWS_PROFILE:-awsconnect81}"
export DATABRICKS_CONFIG_PROFILE="${DATABRICKS_CONFIG_PROFILE:-amazon-agents-account}"
export SNOWFLAKE_ORGANIZATION_NAME="${SNOWFLAKE_ORGANIZATION_NAME:-CNZYESW}"
export SNOWFLAKE_ACCOUNT_NAME="${SNOWFLAKE_ACCOUNT_NAME:-MF87278}"
export SNOWFLAKE_USER="${SNOWFLAKE_USER:-AWSGOALS}"
export SNOWFLAKE_AUTHENTICATOR="${SNOWFLAKE_AUTHENTICATOR:-SNOWFLAKE}"

printf 'Snowflake password: ' >&2
if ! IFS= read -r -s SNOWFLAKE_PASSWORD; then
  printf '\nCould not read password; Terraform was not started.\n' >&2
  exit 1
fi
printf '\n' >&2
if [[ -z "$SNOWFLAKE_PASSWORD" ]]; then
  printf 'Password is empty; Terraform was not started.\n' >&2
  exit 1
fi
export SNOWFLAKE_PASSWORD

# exec preserves the exported credentials without putting them in command arguments.
exec terraform "-chdir=$task_repo_root/infra/environments/dev" "$@"
