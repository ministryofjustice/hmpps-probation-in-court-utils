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

if [ $local = "true" ]
then
  echo "🏠 Running against localstack"
  MATCHER_TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-case-events-topic"
  OPTIONS="--endpoint-url http://localhost:4566"
  AWS_ACCESS_KEY_ID=foobar
  AWS_ACCESS_KEY_ID=foobar
else
  export TOPIC_ARN=$MATCHER_TOPIC_ARN
fi

# Check the topic is accessible
echo "📡 Getting subscriptions to SNS..."

aws sns list-subscriptions-by-topic --topic-arn "$TOPIC_ARN" $OPTIONS
