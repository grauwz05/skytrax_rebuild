#!/usr/bin/env bash
# Run dbt with the rebuild's .env loaded and DBT_PROFILES_DIR pointed correctly.
#   ./setup/dbt.sh debug
#   ./setup/dbt.sh run
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f "$HERE/.env" ]; then
  echo "missing $HERE/.env - copy .env.example and fill it in" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source "$HERE/.env"
set +a

for v in SNOWFLAKE_ACCOUNT SNOWFLAKE_USER SNOWFLAKE_PASSWORD; do
  if [ -z "${!v:-}" ]; then
    echo "$v is empty in .env" >&2
    exit 1
  fi
done

export DBT_PROFILES_DIR="$HERE/profiles"
cd "$HERE/dbt"
exec dbt "$@"
