#!/bin/bash
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
  TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-cases-topic"
  OPTIONS="--endpoint-url http://localhost:4566"
  AWS_ACCESS_KEY_ID=
  AWS_ACCESS_KEY_ID=
else
  export QUEUE_URL=$CRIME_PORTAL_GATEWAY_QUEUE_URL
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
  i=$((i++))
  NEW_CASE_ID=$((1 + $RANDOM % 999999))
  # If there are specified files then only send those, otherwise send everything
  if [[ "$files" == *"$f"* || $files == "" ]]; then
    echo "💻 $i. Processing $f..."
    FILE_PATH="$CASES_PATH/$f"
    PAYLOAD=$(cat "$FILE_PATH")
    PAYLOAD=$(echo $PAYLOAD | sed s/%hearing_date%/$HEARING_DATE/g)
    PAYLOAD=$(echo $PAYLOAD | sed s/%new_case_number%/$NEW_CASE_NO_PREFIX$i/g)
    PAYLOAD=$(echo $PAYLOAD | sed s/%new_case_id%/$NEW_CASE_ID/g)
    echo $PAYLOAD
    aws sqs send-message --endpoint-url https://sqs.eu-west-2.amazonaws.com --queue-url "$QUEUE_URL" --message-body "$PAYLOAD"
  fi
done
