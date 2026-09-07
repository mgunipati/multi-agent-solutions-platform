#!/usr/bin/env bash
set -u

failures=0

check_command() {
  local command_name="$1"
  if command -v "$command_name" >/dev/null 2>&1; then
    printf "[ok] %s: %s\n" "$command_name" "$(command -v "$command_name")"
  else
    printf "[missing] %s\n" "$command_name"
    failures=$((failures + 1))
  fi
}

printf "Multi-Agent Platform development preflight\n\n"
check_command git
check_command terraform
check_command aws
check_command databricks
check_command snow

printf "\nAuthentication checks\n"

if command -v aws >/dev/null 2>&1; then
  if aws sts get-caller-identity >/dev/null 2>&1; then
    printf "[ok] AWS identity is available\n"
  else
    printf "[not connected] AWS: run aws sso login --profile <profile> and export AWS_PROFILE=<profile>\n"
    failures=$((failures + 1))
  fi
fi

if command -v databricks >/dev/null 2>&1; then
  if databricks current-user me >/dev/null 2>&1; then
    printf "[ok] Databricks workspace identity is available\n"
  else
    printf "[not connected] Databricks: run databricks auth login --host <workspace-url>\n"
    failures=$((failures + 1))
  fi
fi

if command -v snow >/dev/null 2>&1; then
  if snow connection test >/dev/null 2>&1; then
    printf "[ok] Snowflake connection is available\n"
  else
    printf "[not connected] Snowflake: configure and test a named connection\n"
    failures=$((failures + 1))
  fi
fi

printf "\nResult: %s issue(s) require attention.\n" "$failures"
exit "$failures"

