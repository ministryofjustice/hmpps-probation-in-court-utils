#!/bin/bash
namespace=court-probation-dev
topic_secret=court-case-events-topic
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
  secret_json=$(cloud-platform decode-secret -s $topic_secret -n $namespace)
  export AWS_ACCESS_KEY_ID=$(echo "$secret_json" | jq -r .data.access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(echo "$secret_json" | jq -r .data.secret_access_key)
  export TOPIC_ARN=$(echo "$secret_json" | jq -r .data.topic_arn)
fi

# Check the topic is accessible
echo "📡 Checking connection to SNS..."
aws sns get-topic-attributes --topic-arn "$TOPIC_ARN" $OPTIONS > /dev/null
#exit_on_error $? !!

# And start publishing the payloads
CASES_PATH="./cases/$namespace"
echo "📂 Checking for cases in $CASES_PATH"
FILES=$(ls $CASES_PATH)
HEARING_DATE=$(date +"%Y\/%m\/%d")
NEW_CASE_NO_PREFIX=$(date +"%y%m%d%M%s")

i=0
for f in $FILES
do
 ((i++))
  # If there are specified files then only send those, otherwise send everything
  if [[ "$files" == *"$f"* || $files == "" ]]; then
   echo "💻 $i. Processing $f..."
   PAYLOAD=$(cat "$CASES_PATH/$f")
   PAYLOAD=$(echo $PAYLOAD | sed s/%hearing_date%/$HEARING_DATE/g)
   PAYLOAD=$(echo $PAYLOAD | sed s/%new_case_number%/$NEW_CASE_NO_PREFIX$i/g)
   echo $PAYLOAD
   aws sns publish --topic-arn "$TOPIC_ARN" --message "$PAYLOAD"
   #exit_on_error $? !!
  fi
done
