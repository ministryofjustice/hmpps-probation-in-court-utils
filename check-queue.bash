#!/bin/bash
namespace=court-probation-dev
queue_secret=court-case-matcher-queue-credentials
local=false

# Note: there can be a noticeable delay on the order of tens of seconds between items being added to or removed from a queue and the count updating.

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

if [[ $local == "true" ]]
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

# Check how many messages are on the queue
echo "📡 Checking queue status for '$QUEUE_URL'..."
aws sqs get-queue-attributes --queue-url="$QUEUE_URL" --attribute-names=ApproximateNumberOfMessages $OPTIONS
