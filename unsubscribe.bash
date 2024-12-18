#!/bin/bash
namespace=court-probation-dev
topic_secret=court-cases-topic
local=false
subscription_arn=

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
  TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-cases-topic.fifo"
  OPTIONS="--endpoint-url http://localhost:4566"
  AWS_ACCESS_KEY_ID=
  AWS_ACCESS_KEY_ID=
else
  export TOPIC_ARN=$MATCHER_TOPIC_ARN
fi

# Check the topic is accessible
echo "📡 Getting subscriptions to SNS..."

aws sns unsubscribe --subscription-arn "$subscription_arn"
