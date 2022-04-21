#!/bin/bash

# 📄 This script will zip up the public cert and put it on the $ftp_server. The password will be saved locally in the
# 📄 namespace folder and should be sent to the recipient through a different channel. You will be prompted to provide
# 📄 a password.


env=preprod
zip_pass=$(openssl rand -base64 8)
ftp_server=public.cgi.com

# Read any named params
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

  shift
done
namespace=court-probation-$env
working_directory=~/temp/$namespace
public_cert_path=$working_directory/crime-portal-gateway.crt
zip_path=$working_directory/crime-portal-gateway-$env.zip
zip_pass_path=$zip_path.pass
ftp_path=/public_html/keystore-$env.zip

set -e

echo "🗜 Zipping $public_cert_path"
zip $zip_path $public_cert_path -ej -P $zip_pass

echo "🔑 Saving zip password to $zip_pass_path"
echo -n $zip_pass > $zip_pass_path

echo "⬆️ Uploading public certificate to $ftp_path"

scp $zip_path "${ftp_user:? ⚠️ Parameter --ftp_user is required}@$ftp_server:$ftp_path"
