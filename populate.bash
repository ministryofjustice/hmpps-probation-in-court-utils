#!/bin/bash
namespace=court-probation-dev
topic_secret=court-case-events-topic
local=false

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

for f in $FILES
do
 echo "💻 Processing $f..."
 PAYLOAD=$(cat "$CASES_PATH/$f")
 aws sns publish --topic-arn "$TOPIC_ARN" --message "$PAYLOAD" $OPTIONS > /dev/null
 #exit_on_error $? !!
done
