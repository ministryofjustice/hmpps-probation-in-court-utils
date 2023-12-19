#!/bin/bash
namespace=court-probation-dev
topic_secret=court-case-events-topic
local=false
files=
message_type=LIBRA_COURT_CASE
court_code=B14LO

set -x
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

if [ "$local" = "true" ]
then
  echo "🏠 Running against localstack"
  TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-case-events-topic"
  OPTIONS="--endpoint-url http://localhost:4566"
  AWS_ACCESS_KEY_ID=
  AWS_ACCESS_KEY_ID=
else
  export TOPIC_ARN=$MATCHER_TOPIC_ARN
fi

# Check the topic is accessible
echo "📡 Checking connection to SNS..."
aws sns get-topic-attributes --topic-arn "$TOPIC_ARN" $OPTIONS > /dev/null
#exit_on_error $? !!

# And start publishing the payloads
CASES_PATH="./cases/$namespace/libra-cases"
echo "📂 Checking for cases in $CASES_PATH"
FILES=$(ls $CASES_PATH)
HEARING_DATE=$(date +"%Y\-%m\-%d")
NEW_CASE_NO_PREFIX=$(date +"%y%m%d%M%s")

i=0
for f in $FILES
do
  ((i++))
  # This can be used when we support a message type of CP_COURT_CASE
  # NEW_CASE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
  NEW_CASE_ID=$((1 + $RANDOM % 999999))
  # If there are specified files then only send those, otherwise send everything
  if [[ "$files" == *"$f"* || $files == "" ]]; then
    echo "💻 $i. Processing $f..."
    FILE_PATH="$CASES_PATH/$f"
    PAYLOAD=$(cat "$FILE_PATH")
    PAYLOAD=$(echo $PAYLOAD | sed s/%hearing_date%/$HEARING_DATE/g)
    PAYLOAD=$(echo $PAYLOAD | sed s/%new_case_number%/$NEW_CASE_NO_PREFIX$i/g)
    PAYLOAD=$(echo $PAYLOAD | sed s/%new_case_id%/$NEW_CASE_ID/g)
    PAYLOAD=$(echo $PAYLOAD | sed s/%court_code%/$court_code/g)
    echo "${PAYLOAD}"
    aws sns publish --topic-arn "$TOPIC_ARN" --message "$PAYLOAD" --message-attributes "{\"messageType\" : { \"DataType\":\"String\", \"StringValue\":\"$message_type\"}}" $OPTIONS
   #exit_on_error $? !!
  fi
done
