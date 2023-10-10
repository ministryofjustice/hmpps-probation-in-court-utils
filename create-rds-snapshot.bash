#!/bin/bash
snapshot_identifier=court-case-service-manual-snapshot-$(date +%s)

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

export INSTANCE_IDENTIFIER=$RDS_INSTANCE_IDENTIFIER

echo "📸 Creating snapshot '$snapshot_identifier'"
aws rds create-db-snapshot --db-instance-identifier "$INSTANCE_IDENTIFIER" --db-snapshot-identifier "$snapshot_identifier"
