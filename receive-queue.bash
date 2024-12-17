#!/bin/bash
namespace={$namespace:-court-probation-dev}
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
  TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-cases-topic"
  OPTIONS="--endpoint-url http://localhost:4566"
  QUEUE_URL="http://localhost:4566/000000000000/test-queue"
  AWS_ACCESS_KEY_ID=foobar
  AWS_SECRET_ACCESS_KEY=foobar
else
  export QUEUE_URL=$MATCHER_QUEUE_URL
fi

echo "✉️ Getting message from queue '$QUEUE_URL'..."
FILENAME=message-$(date "+%Y-%m-%dT%H-%M-%S").json
OUTPUT_DIRECTORY=/tmp/$namespace/
mkdir -p $OUTPUT_DIRECTORY
aws sqs receive-message --region eu-west-2 --queue-url=$QUEUE_URL $OPTIONS > $OUTPUT_DIRECTORY$FILENAME
