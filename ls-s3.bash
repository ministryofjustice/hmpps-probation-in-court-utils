#!/bin/bash
options=--recursive

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

export BUCKET_NAME=$CRIME_PORTAL_GATEWAY_BUCKET_NAME

echo "🗂️ Listing files in '$BUCKET_NAME$path'..."
aws s3 ls s3://$BUCKET_NAME$path $options
