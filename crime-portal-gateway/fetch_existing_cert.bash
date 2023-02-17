#!/bin/bash

# 📄 Fetches the existing keystore from the namespace and creates a local copy, updated with the provided
# 📄 --trusted_cert with alias $trusted_alias. It retains the same private key and password.

# 📄 Once this script is run, you can check the keystore with ./read_generated_keystore.bash
# 📄 If you're happy you can apply it with ./update_secrets.bash (Note: it uses the same keystore password so you don't
# 📄 need to update this)

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
