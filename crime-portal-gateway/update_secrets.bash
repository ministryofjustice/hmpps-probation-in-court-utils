#!/bin/bash
namespace=court-probation-dev
update_keystore_password=false

# Read any named params
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

  shift
done

working_directory=~/temp/$namespace
keystore_name=crime-portal-gateway-jks.key
keystore_path=$working_directory/$keystore_name
password_path=$keystore_path.pwd
cert_secret=crime-portal-gateway-keystore-cert
app_secrets=crime-portal-gateway-secrets

kubectl config use-context $namespace
echo "🗃 Backing up existing secrets to $working_directory"
app_secrets_backup_path=$working_directory/$app_secrets.json.bk
cert_secret_backup_path=$working_directory/$cert_secret.json.bk
kubectl get secret $cert_secret -n $namespace -o json > $cert_secret_backup_path
kubectl get secret $app_secrets -n $namespace -o json > $app_secrets_backup_path

echo "💾 Saving new keystore"
kubectl delete secret $cert_secret
kubectl create secret generic $cert_secret --from-file=$keystore_name=$keystore_path


if [[ $update_keystore_password = "true" ]]
then
  echo "💾 Updating keystore password"
  updated_app_secrets_path=$working_directory/${app_secrets}-updated.json
  encoded_password=$(cat $password_path | base64)
  cat $app_secrets_backup_path | jq --arg a "$encoded_password" '.data.KEYSTORE_PASSWORD = $a' > $updated_app_secrets_path
  kubectl replace secret $app_secret -f $updated_app_secrets_path
fi
