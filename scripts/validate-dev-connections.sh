#!/usr/bin/env bash
set -u

aws_profile="${AWS_PROFILE:-awsconnect81}"
databricks_profile="${DATABRICKS_CONFIG_PROFILE:-amazon-agents-account}"
snowflake_connection="${SNOWFLAKE_CONNECTION_NAME:-agentic-dev}"
failures=0

printf "AWS\n"
if aws sts get-caller-identity --profile "$aws_profile" --region us-west-2; then
  printf "[ok] AWS profile %s\n\n" "$aws_profile"
else
  failures=$((failures + 1))
fi

printf "Databricks\n"
if databricks current-user me --profile "$databricks_profile"; then
  printf "[ok] Databricks profile %s\n\n" "$databricks_profile"
else
  failures=$((failures + 1))
fi

printf "Snowflake\n"
if snow connection test --connection "$snowflake_connection"; then
  printf "[ok] Snowflake connection %s\n\n" "$snowflake_connection"
else
  failures=$((failures + 1))
fi

printf "Validation completed with %s failure(s).\n" "$failures"
exit "$failures"
