#!/bin/bash
namespace=court-probation-dev
s3_secret=crime-portal-gateway-s3-credentials
path=
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

# Get credentials and queue details from namespace secret
echo "🔑 Getting credentials for $namespace..."
secret_json=$(cloud-platform decode-secret -s $s3_secret -n $namespace  --skip-version-check)
export AWS_ACCESS_KEY_ID=$(echo "$secret_json" | jq -r .data.access_key_id)
export AWS_SECRET_ACCESS_KEY=$(echo "$secret_json" | jq -r .data.secret_access_key)
export BUCKET_NAME=$(echo "$secret_json" | jq -r .data.bucket_name)


echo "🗂️ Listing files in '$BUCKET_NAME$path'..."
aws s3 ls s3://$BUCKET_NAME$path $options
