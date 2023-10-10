#!/bin/bash

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

aws rds describe-db-snapshots --db-instance-identifier "$INSTANCE_IDENTIFIER"

