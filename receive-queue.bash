#!/bin/bash
namespace=court-probation-dev
queue_secret=court-case-matcher-queue-dead-letter-queue-credentials
local=false
OPTIONS=--visibility-timeout=120

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
  QUEUE_URL="http://localhost:4566/000000000000/test-queue"
  AWS_ACCESS_KEY_ID=foobar
  AWS_SECRET_ACCESS_KEY=foobar
else
  # Get credentials and queue details from namespace secret
  echo "🔑 Getting credentials for $namespace..."
  secret_json=$(cloud-platform decode-secret -s $queue_secret -n $namespace --skip-version-check)
  export AWS_ACCESS_KEY_ID=$(echo "$secret_json" | jq -r .data.access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(echo "$secret_json" | jq -r .data.secret_access_key)
  export QUEUE_URL=$(echo "$secret_json" | jq -r .data.sqs_id)
fi

echo "✉️ Getting message from queue '$QUEUE_URL'..."
FILENAME=message-$(date "+%Y-%m-%dT%H-%M-%S").json
OUTPUT_DIRECTORY=~/temp/$namespace/
mkdir -p $OUTPUT_DIRECTORY
aws sqs receive-message --region eu-west-2 --queue-url=$QUEUE_URL $OPTIONS > $OUTPUT_DIRECTORY$FILENAME
