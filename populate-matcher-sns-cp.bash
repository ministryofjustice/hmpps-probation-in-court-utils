#!/bin/bash
namespace=court-probation-dev
topic_secret=court-case-events-topic
local=false
files=
message_type=COMMON_PLATFORM_HEARING
cp_base_path="./cases/$namespace/common-platform-hearings/"
cases_path=""
generate_ids=true
recurse_max_depth=1
court_code=B14LO

export AWS_REGION=eu-west-2

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

if [[ $local = "true" ]]
then
  echo "🏠 Running against localstack"
  TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-case-events-topic"
  OPTIONS="--endpoint-url http://localhost:4566"
  AWS_ACCESS_KEY_ID=
  AWS_ACCESS_KEY_ID=
else
  # Get credentials and queue details from namespace secret
  echo "🔑 Getting credentials for $namespace..."
#  secret_json=$(kubectl get secret court-case-events-topic -o json)
#  export AWS_ACCESS_KEY_ID=$(echo "$secret_json" | jq -r .data.access_key_id)
#  export AWS_SECRET_ACCESS_KEY=$(echo "$secret_json" | jq -r .data.secret_access_key)
#  export TOPIC_ARN=$(echo "$secret_json" | jq -r .data.topic_arn)
fi

# Check the topic is accessible
echo "📡 Checking connection to SNS..."
aws sns get-topic-attributes --topic-arn "$TOPIC_ARN" $OPTIONS > /dev/null
#exit_on_error $? !!

if [[ -n "${cases_path}" ]]
then
  recurse_max_depth=10
fi
CASES_PATH="${cp_base_path}${cases_path}"
FILES=$(find $CASES_PATH -maxdepth $recurse_max_depth -type f)
echo "📂 Checking for cases in ${CASES_PATH}"
HEARING_DATE=$(date +"%Y-%m-%d")
TOMORROW_DATE=$(date -d "+1 days" +"%Y-%m-%d")

i=0
echo "The files are ... $FILES"

for case_file in $FILES
do
  echo "In for loop... $case_file"

  i=$((i++))

  echo "Incremented i $i..."

  file=$(basename "${case_file}")
  echo "💻 $i. Processing $case_file..."

  # If there are specified files then only send those, otherwise send everything
  if [[ "$files" == *"${file}"* || $files == "" ]]; then

    # Temporary ignore files we can't send to SNS
    file_size=$(du -shk ${case_file} | cut -f1)
    if [[ $file_size -gt 256 ]]
    then
      echo $case_file has size of $file_size and is too large, ignoring
      continue
    fi

    PAYLOAD=$(cat "${case_file}")

    if [[ $generate_ids = "true" ]]
    then
      NEW_CASE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
      NEW_HEARING_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
      NEW_DEFENDANT_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
      NEW_DEFENDANT_ID_2=$(uuidgen | tr '[:upper:]' '[:lower:]')
      NEW_OFFENCE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
      PAYLOAD=$(echo $PAYLOAD | sed s/%hearing_date%/$HEARING_DATE/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%hearing_date_2%/$TOMORROW_DATE/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%new_case_id%/$NEW_CASE_ID/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%new_hearing_id%/$NEW_HEARING_ID/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%new_defendant_id%/$NEW_DEFENDANT_ID/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%new_defendant_id_2%/$NEW_DEFENDANT_ID_2/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%new_offence_id%/$NEW_OFFENCE_ID/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%court_code%/$court_code/g)
    fi
    
    MSG_ATTRIBS="{\"messageType\" : { \"DataType\":\"String\", \"StringValue\":\"$message_type\"}, \"hearingEventType\" : { \"DataType\":\"String\", \"StringValue\":\"Unknown\"}}"

    echo "${PAYLOAD}"
    aws sns publish --topic-arn "$TOPIC_ARN" --message "$PAYLOAD" --message-attributes "$MSG_ATTRIBS" $OPTIONS
    #exit_on_error $? !!
  fi
done

echo "Script completed"
