#!/bin/bash
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


if [[ $email == "" ]]
then
  echo "⚠️ Parameter '--email' is required for subscription"
  exit 1
fi

if [ $local = "true" ]
then
  echo "🏠 Running against localstack"
  MATCHER_TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-cases-topic"
  OPTIONS="--endpoint-url http://localhost:4566"
  AWS_ACCESS_KEY_ID=
  AWS_ACCESS_KEY_ID=
else
  export TOPIC_ARN=$MATCHER_TOPIC_ARN
fi

# Check the topic is accessible
echo "📡 Checking connection to SNS..."
aws sns get-topic-attributes --topic-arn "$TOPIC_ARN" $OPTIONS > /dev/null

aws sns subscribe --topic-arn "$TOPIC_ARN" --protocol email-json --notification-endpoint "$email" $OPTIONS
