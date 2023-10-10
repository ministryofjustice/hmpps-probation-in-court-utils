#!/bin/bash
output_folder=/tmp
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
export BUCKET_NAME=$CRIME_PORTAL_GATEWAY_BUCKET_NAME

OUTPUT_PATH=$output_folder/$BUCKET_NAME/$bucket_path
echo "🗂️ Copying files from '$BUCKET_NAME/$bucket_path' to '$OUTPUT_PATH'..."
aws s3 cp s3://$BUCKET_NAME/$bucket_path $OUTPUT_PATH $options "$@" # this passes all teh options - see this if your command is failing
