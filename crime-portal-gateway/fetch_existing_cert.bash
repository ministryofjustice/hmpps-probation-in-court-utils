#!/bin/bash

# 📄 Fetches the existing keystore from the namespace and exports the trusted cert to a file which can then be imported
# 📄 to a new keystore

# 📄 Once this script is run, you can check cert with read_existing_cert_from_local.bash

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
keystore_path=$working_directory/crime-portal-gateway-jks.key
password_path=$keystore_path.pwd

echo "🐕 Fetching existing keystore and copying to $keystore_path"
kubectl config use-context $namespace
kubectl get secret crime-portal-gateway-keystore-cert -n $namespace -o json | jq -r '.data."crime-portal-gateway-jks.key"' | base64 -D > $keystore_path
KEYSTORE_PASSWORD=$(kubectl get secret crime-portal-gateway-secrets -n $namespace -o json | jq -r '.data | map_values(@base64d).KEYSTORE_PASSWORD')
echo "🔑 Saving keystore password to $password_path"
echo -n $KEYSTORE_PASSWORD > $password_path

EXISTING_CERT_PATH=$working_directory/existing_${trusted_alias}.crt
echo "📦 Exporting existing $trusted_alias cert from $keystore_path to $EXISTING_CERT_PATH"
keytool -export -alias $trusted_alias -file $EXISTING_CERT_PATH -keystore $keystore_path -storepass $KEYSTORE_PASSWORD
