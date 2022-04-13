#!/bin/bash
namespace=court-probation-dev
queue_secret=court-case-service-rds-instance-output
snapshot_identifier=

# Read any named params
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

  shift
done

set -o history -o histexpand
set -e

# Get credentials and rds details from namespace secret
echo "🔑 Getting credentials for $namespace..."
secret_json=$(cloud-platform decode-secret -s $queue_secret -n $namespace --skip-version-check)
export AWS_ACCESS_KEY_ID=$(echo "$secret_json" | jq -r .data.access_key_id)
export AWS_SECRET_ACCESS_KEY=$(echo "$secret_json" | jq -r .data.secret_access_key)
export INSTANCE_IDENTIFIER=$(echo "$secret_json" | jq -r .data.rds_instance_address | sed s/[.].*//)

echo "🔥 Deleting snapshot '$snapshot_identifier'"
aws rds delete-db-snapshot --db-snapshot-identifier "${snapshot_identifier:? ⚠️ ️ Please provide a --snapshot_identifier to delete}"
