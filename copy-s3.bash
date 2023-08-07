#!/bin/bash
namespace=court-probation-dev
s3_secret=crime-portal-gateway-s3-credentials
output_folder=~/temp
bucket_path=
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

OUTPUT_PATH=$output_folder/$BUCKET_NAME/$bucket_path
echo "🗂️ Copying files from '$BUCKET_NAME/$bucket_path' to '$OUTPUT_PATH'..."
aws s3 cp s3://$BUCKET_NAME/$bucket_path $OUTPUT_PATH --recursive --exclude="*" --include="2023-08-07-B10LX*.xml"
#############################################################################################################
# Modify the above --include filter to only copy a subset of the files in the bucket to the local filesystem
# The --exclude="*" is also required according to the aws cli docs:
# https://docs.aws.amazon.com/cli/latest/reference/s3/index.html#use-of-exclude-and-include-filters
#############################################################################################################