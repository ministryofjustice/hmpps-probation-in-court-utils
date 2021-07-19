#!/bin/bash
namespace=court-probation-dev
topic_secret=court-case-events-topic
local=false
email=

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
  secret_json=$(cloud-platform decode-secret -s $topic_secret -n $namespace --skip-version-check)
  export AWS_ACCESS_KEY_ID=$(echo "$secret_json" | jq -r .data.access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(echo "$secret_json" | jq -r .data.secret_access_key)
  export TOPIC_ARN=$(echo "$secret_json" | jq -r .data.topic_arn)
fi

# Check the topic is accessible
echo "📡 Getting subscriptions to SNS..."

aws sns set-subscription-attributes --subscription-arn \
"arn:aws:sns:eu-west-2:754256621582:cloud-platform-probation-in-court-team-5b4824dca700d8b3ec75f25d24adfbb9:9de23d20-a783-43ba-9a7f-dd22fc924755" \
--attribute-name FilterPolicy --attribute-value "{\"messageType\": [\"LIBRA_COURT_CASE\"]}"

