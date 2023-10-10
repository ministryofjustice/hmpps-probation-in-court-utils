#!/bin/bash

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
  export QUEUE_URL=$MATCHER_QUEUE_URL
fi

# Check how many messages are on the queue
echo "📡 Checking queue status for '$QUEUE_URL'..."
aws sqs get-queue-attributes --queue-url="$QUEUE_URL" --attribute-names=ApproximateNumberOfMessages $OPTIONS
