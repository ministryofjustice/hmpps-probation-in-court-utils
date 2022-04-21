#!/bin/bash
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

echo "🚚 Cert '${trusted_cert:? ⚠️ --trusted_cert parameter is required to update keystore}' will be added to the generated keystore"
echo "🐕 Fetching existing keystore and copying to $keystore_path"
kubectl config use-context $namespace
kubectl get secret crime-portal-gateway-keystore-cert -n $namespace -o json | jq -r '.data."crime-portal-gateway-jks.key"' | base64 -D > $keystore_path
KEYSTORE_PASSWORD=$(kubectl get secret crime-portal-gateway-secrets -n $namespace -o json | jq -r '.data | map_values(@base64d).KEYSTORE_PASSWORD')
echo "🔑 Saving keystore password to $password_path"
echo -n $KEYSTORE_PASSWORD > $password_path

echo "🔥 Deleting existing trusted cert '$trusted_alias'"
keytool -delete -alias $trusted_alias -keystore $keystore_path -storepass $KEYSTORE_PASSWORD

echo "🗃 Adding trusted cert '${trusted_cert}' to keystore"
keytool -import -trustcacerts -alias $trusted_alias -file $trusted_cert -keystore $keystore_path -storepass $KEYSTORE_PASSWORD -noprompt

echo "🎉 Keystore at '$keystore_path' has been updated with trusted cert '$trusted_cert'"
