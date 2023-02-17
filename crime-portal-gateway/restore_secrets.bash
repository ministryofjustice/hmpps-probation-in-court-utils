#!/bin/bash

# 📄 This script will restore backed up secrets from the latest backups for the provided namespace
# 🐛 Known issue: The backups contain metadata, including the uid of the secret as it was. As these are unique you will
# 🐛 have to manually remove this item from the metadata or it will fail to apply.
# 🐛 This can't easily be scripted because though you can use | sed '/\"uid\"/d' to remove the offending line, it will
# 🐛 generally leave a trailing comma as well which is much harder to get rid of. Obviously possible but hasn't been
# 🐛 worth the effort so far.


namespace=court-probation-dev

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
echo "🗃 Restoring secrets from $working_directory"
app_secrets_backup_path=$working_directory/$app_secrets.json.bk
cert_secret_backup_path=$working_directory/$cert_secret.json.bk

kubectl replace secret $app_secret -f $app_secrets_backup_path
kubectl replace secret $cert_secret -f $cert_secret_backup_path

echo "♻️ Restarting pods"
kubectl rollout restart deployment crime-portal-gateway
