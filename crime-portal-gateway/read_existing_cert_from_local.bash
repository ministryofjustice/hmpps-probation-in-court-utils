#!/bin/bash

# 📄 Reads a locally saved trusted cert from existing_cgiextgw.crt


set -e

namespace=court-probation-dev
trusted_alias=cgiextgw

# Read any named params
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

  shift
done
working_directory=~/temp/$namespace

EXISTING_CERT_PATH=$working_directory/existing_${trusted_alias}.crt
if [[ ! -f "$EXISTING_CERT_PATH" ]];
then
  echo "⚠️ Existing cert at $EXISTING_CERT_PATH does not exist."
  echo "👋 Exiting"
  exit 1
fi

echo "📖 Reading existing $trusted_alias cert from $EXISTING_CERT_PATH"
keytool -printcert -v -file $EXISTING_CERT_PATH
