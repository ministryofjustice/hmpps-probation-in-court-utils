#!/bin/bash
namespace=court-probation-dev
topic_secret=court-case-events-topic
local=false
files=
message_type=COMMON_PLATFORM_HEARING

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

if [[ $local = "true" ]]
then
  echo "🏠 Running against localstack"
  TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-case-events-topic"
  OPTIONS="--endpoint-url http://localhost:4566"
  AWS_ACCESS_KEY_ID=
  AWS_ACCESS_KEY_ID=
else
  # Get credentials and queue details from namespace secret
  echo "🔑 Getting credentials for $namespace..."
  secret_json=$(cloud-platform decode-secret -s $topic_secret -n $namespace --skip-version-check)
  export AWS_ACCESS_KEY_ID=$(echo "$secret_json" | jq -r .data.access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(echo "$secret_json" | jq -r .data.secret_access_key)
  export TOPIC_ARN=$(echo "$secret_json" | jq -r .data.topic_arn)
fi

# Check the topic is accessible
echo "📡 Checking connection to SNS..."
aws sns get-topic-attributes --topic-arn "$TOPIC_ARN" $OPTIONS > /dev/null
#exit_on_error $? !!

# And start publishing the payloads
CASES_PATH="./cases/$namespace/common-platform-hearings"
echo "📂 Checking for cases in $CASES_PATH"
FILES=$(ls $CASES_PATH)
HEARING_DATE=$(date +"%Y\-%m\-%d")

i=0
for f in $FILES
do
  ((i++))
  NEW_CASE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
  NEW_DEFENDANT_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
  NEW_OFFENCE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
  # If there are specified files then only send those, otherwise send everything
  if [[ "$files" == *"$f"* || $files == "" ]]; then
    echo "💻 $i. Processing $f..."
    FILE_PATH="$CASES_PATH/$f"
    PAYLOAD=$(cat "$FILE_PATH")
    PAYLOAD=$(echo $PAYLOAD | sed s/%hearing_date%/$HEARING_DATE/g)
    PAYLOAD=$(echo $PAYLOAD | sed s/%new_case_id%/$NEW_CASE_ID/g)
    PAYLOAD=$(echo $PAYLOAD | sed s/%new_defendant_id%/$NEW_DEFENDANT_ID/g)
    PAYLOAD=$(echo $PAYLOAD | sed s/%new_offence_id%/$NEW_OFFENCE_ID/g)
    echo "${PAYLOAD}"
    aws sns publish --topic-arn "$TOPIC_ARN" --message "$PAYLOAD" --message-attributes "{\"messageType\" : { \"DataType\":\"String\", \"StringValue\":\"$message_type\"}}" $OPTIONS
   #exit_on_error $? !!
  fi
done