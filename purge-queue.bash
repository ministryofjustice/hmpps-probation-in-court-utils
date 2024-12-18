#!/bin/bash
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
  TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-cases-topic.fifo"
  OPTIONS="--endpoint-url http://localhost:4566"
  QUEUE_URL="http://localhost:4566/000000000000/court-case-matcher-queue.fifo"
  AWS_ACCESS_KEY_ID=
  AWS_DEFAULT_REGION=eu-west-2
else
  export QUEUE_URL=$MATCHER_DLQ_QUEUE_URL
fi

# Check how many messages are on the queue
echo "🔥 Purging messages from queue '$QUEUE_URL'..."
aws sqs purge-queue --queue-url=$QUEUE_URL $OPTIONS
