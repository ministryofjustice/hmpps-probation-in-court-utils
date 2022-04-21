#!/bin/bash
namespace=court-probation-dev

# Read any named params
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

  shift
done

kubectl config use-context $namespace
kubectl get secret crime-portal-gateway-keystore-cert -n $namespace -o json | jq -r '.data."crime-portal-gateway-jks.key"' | base64 -D > /tmp/crime-portal-gateway-jks.key
KEYSTORE_PASSWORD=$(kubectl get secret crime-portal-gateway-secrets -n $namespace -o json | jq -r '.data | map_values(@base64d).KEYSTORE_PASSWORD')
keytool -list -v -keystore /tmp/crime-portal-gateway-jks.key  -storepass "$KEYSTORE_PASSWORD"
rm /tmp/crime-portal-gateway-jks.key
