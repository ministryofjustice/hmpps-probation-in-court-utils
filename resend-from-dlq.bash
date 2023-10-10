#!/bin/bash
namespace={$namespace:-court-probation-dev}
queue_secret=court-case-matcher-queue-credentials
dlq_secret=court-case-matcher-queue-dead-letter-queue-credentials
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
  echo "🏠 Not implemented! Exiting"
  exit 1
else
  export DLQ_URL=$MATCHER_DLQ_QUEUE_URL
fi


echo "✉️ Getting message from DLQ '$DLQ_URL'..."
bk_file="dlq_message_$(date "+%Y-%m-%d_%H-%M-%S").bk"
echo "💾 Backing up message to $bk_file"
aws sqs receive-message --queue-url=$DLQ_URL > "$bk_file"
PAYLOAD="$(cat $bk_file  | jq .Messages[0].Body)"


if [ $PAYLOAD = "" ]
then
  echo "🤷‍♀️No message was received, exiting."
  exit 1
fi

echo "📦️ Payload is:"
echo $PAYLOAD


if [ $local = "true" ]
then
  echo "🏠 Not implemented! Exiting"
  exit 1
else
  export QUEUE_URL=$MATCHER_QUEUE_URL
fi

echo "✉️ Resending message from DLQ '$DLQ_URL' to ..."
aws sqs send-message --queue-url $QUEUE_URL --message-body "$PAYLOAD"

