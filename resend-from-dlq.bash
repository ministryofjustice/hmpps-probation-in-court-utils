#!/bin/bash
namespace=court-probation-dev
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
  # Get credentials and queue details from namespace secret
  echo "🔑 Getting DLQ credentials for $namespace..."
  secret_json=$(cloud-platform decode-secret -s $dlq_secret -n $namespace --skip-version-check)
  export AWS_ACCESS_KEY_ID=$(echo "$secret_json" | jq -r .data.access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(echo "$secret_json" | jq -r .data.secret_access_key)
  export DLQ_URL=$(echo "$secret_json" | jq -r .data.sqs_id)
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
  echo "🔑 Getting queue credentials for $namespace..."
  secret_json=$(cloud-platform decode-secret -s $queue_secret -n $namespace --skip-version-check)
  export AWS_ACCESS_KEY_ID=$(echo "$secret_json" | jq -r .data.access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(echo "$secret_json" | jq -r .data.secret_access_key)
  export QUEUE_URL=$(echo "$secret_json" | jq -r .data.sqs_id)
fi

echo "✉️ Resending message from DLQ '$DLQ_URL' to ..."
aws sqs send-message --queue-url $QUEUE_URL --message-body "$PAYLOAD"

