#!/bin/bash
namespace=court-probation-dev
queue_secret=crime-portal-gateway-queue-credentials
local=false
files=

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
exit_on_error() {
    exit_code=$1
    last_command=${@:2}
    if [ $exit_code -ne 0 ]; then
        >&2 echo "💥 Last command:"
        >&2 echo "    \"${last_command}\""
        >&2 echo "❌ Failed with exit code ${exit_code}."
        >&2 echo "🟥 Aborting"
        exit $exit_code
    fi
}

if [ $local = "true" ]
then
  echo "🏠 Running against localstack"
  TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-case-events-topic"
  OPTIONS="--endpoint-url http://localhost:4566"
  AWS_ACCESS_KEY_ID=
  AWS_ACCESS_KEY_ID=
else
  # Get credentials and queue details from namespace secret
  echo "🔑 Getting credentials for $namespace..."
  secret_json=$(cloud-platform decode-secret -s $queue_secret -n $namespace --skip-version-check)
  export AWS_ACCESS_KEY_ID=$(echo "$secret_json" | jq -r .data.access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(echo "$secret_json" | jq -r .data.secret_access_key)
  export QUEUE_URL=$(echo "$secret_json" | jq -r .data.sqs_id)

fi

# And start publishing the payloads
CASES_PATH="./cases/$namespace/lists"
echo "📂 Checking for cases in $CASES_PATH"
FILES=$(ls $CASES_PATH)
HEARING_DATE=$(date +"%d\/%m\/%Y")
NEW_CASE_NO_PREFIX=$(date +"%y%m%d%M%s")

i=0
for f in $FILES
do
 ((i++))
  # If there are specified files then only send those, otherwise send everything
  if [[ "$files" == *"$f"* || $files == "" ]]; then
   echo "💻 $i. Processing $f..."
   FILE_PATH="$CASES_PATH/$f"
   PAYLOAD=$(cat "$FILE_PATH")
   PAYLOAD=$(echo $PAYLOAD | sed s/%hearing_date%/$HEARING_DATE/g)
   PAYLOAD=$(echo $PAYLOAD | sed s/%new_case_number%/$NEW_CASE_NO_PREFIX$i/g)
   echo $PAYLOAD
aws sqs send-message --endpoint-url https://sqs.eu-west-2.amazonaws.com --queue-url "$QUEUE_URL" --message-body "$PAYLOAD"
  fi
done
