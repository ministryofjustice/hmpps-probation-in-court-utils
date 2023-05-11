#!/bin/bash
namespace=court-probation-dev
secret=court-hearing-event-receiver
local=false
files=
message_type=COMMON_PLATFORM_HEARING
cp_base_path="./cases/$namespace/common-platform-hearings/"
cases_path=""
generate_ids=true
recurse_max_depth=1
host=https://court-hearing-event-receiver-dev.hmpps.service.justice.gov.uk
auth_host=https://sign-in-dev.hmpps.service.justice.gov.uk
client_id=
client_secret=

# Read personal HMPPS Auth client id and secret from the command line
read -p "Enter your client_id: " client_id

if [[ -z "$client_id" ]]; then
  echo "Error: no client_id provided"
  exit 1
fi

read -p "Enter your client_secret: " client_secret

if [[ -z "$client_secret" ]]; then
  echo "Error: no client_secret provided"
  exit 1
fi

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

authenticate() {
  auth_header="Authorization: Basic $(echo -n "$client_id:$client_secret" | base64)"
  url=$auth_host/auth/oauth/token
  token="$(curl -X POST \
    -H application/x-www-form-urlencoded \
    -H "$auth_header" -F grant_type=client_credentials -F scope=read \
    https://sign-in-dev.hmpps.service.justice.gov.uk/auth/oauth/token \
    | jq -r .access_token
    )"
    echo "🔑 Token returned = $token"
}

if [[ $local = "true" ]]
then
  echo "🏠 Running against local"
  host=http://localhost:8080
fi


if [[ -n "${cases_path}" ]]
then
  recurse_max_depth=10
fi
CASES_PATH="${cp_base_path}${cases_path}"
FILES=$(find $CASES_PATH -maxdepth $recurse_max_depth -type f)
echo "📂 Checking for cases in ${CASES_PATH}"
HEARING_DATE=$(date +"%Y\-%m\-%d")
TOMORROW_DATE=$(date -v+1d +"%Y\-%m\-%d")

i=0
for case_file in $FILES
do
  ((i++))
  file=$(basename "${case_file}")

  # If there are specified files then only send those, otherwise send everything
  if [[ "$files" == *"${file}"* || $files == "" ]]; then
    echo "💻 $i. Processing $case_file..."
    PAYLOAD=$(cat "${case_file}")

    if [[ $generate_ids = "true" ]]
    then
      NEW_HEARING_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
      NEW_CASE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
      NEW_DEFENDANT_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
      NEW_DEFENDANT_ID_2=$(uuidgen | tr '[:upper:]' '[:lower:]')
      NEW_OFFENCE_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
      PAYLOAD=$(echo $PAYLOAD | sed s/%new_hearing_id%/$NEW_HEARING_ID/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%hearing_date%/$HEARING_DATE/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%hearing_date_2%/$TOMORROW_DATE/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%new_case_id%/$NEW_CASE_ID/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%new_defendant_id%/$NEW_DEFENDANT_ID/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%new_defendant_id_2%/$NEW_DEFENDANT_ID_2/g)
      PAYLOAD=$(echo $PAYLOAD | sed s/%new_offence_id%/$NEW_OFFENCE_ID/g)
    fi
    echo "${PAYLOAD}"

  authenticate
  echo "🔑 After authenticate......."

  curl -i -X POST \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $token" \
  -d "$PAYLOAD" \
  "$host/hearing/$NEW_HEARING_ID"
  fi
done
