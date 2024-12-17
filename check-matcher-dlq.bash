#!/bin/bash
local=${local_env:-false}

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
  MATCHER_TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-cases-topic"
  OPTIONS="--endpoint-url http://localhost:4566"
  AWS_ACCESS_KEY_ID=
  AWS_ACCESS_KEY_ID=
else
  export QUEUE_URL=$MATCHER_DLQ_URL
fi

# Check how many messages are on the queue
echo "📡 Checking queue status for '$QUEUE_URL'..."
aws sqs get-queue-attributes --queue-url=$QUEUE_URL --attribute-names=ApproximateNumberOfMessages
