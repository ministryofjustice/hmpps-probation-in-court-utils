#!/bin/bash
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

export INSTANCE_IDENTIFIER=$RDS_INSTANCE_IDENTIFIER

echo "🔥 Deleting snapshot '$snapshot_identifier'"
aws rds delete-db-snapshot --db-snapshot-identifier "${snapshot_identifier:? Please provide a --snapshot_identifier to delete}"
