#!/bin/bash

# 📄 Generates a brand new keystore containing a newly generated private key and add a provided --trusted_cert
# 📄 cert. This keystore file will be added to a temporary folder named ~/temp/{namespace} along with
# 📄 a file containing the keystore password, and a separate file containing the private key password. It will also add
# 📄 a public certificate signed by the generated private key to the folder. You will have to create this folder if it
# 📄 doesn't already exist.

# 📄 Once this script is run, you can check the keystore with ./read_generated_keystore.bash or cert with ./read_generated_cert.bash
# 📄 If you're happy you can apply it with `./update_secrets.bash --update_keystore_password true`.


namespace=court-probation-dev
cert_cn=crime-portal-gateway
cert_ou=MoJ
cert_o=MoJ
cert_l=Sheffield
cert_st="South Yorkshire"
cert_c=UK
cert_validity=365
trusted_alias=cgiextgw
key_alias=mgwextdoc
keystore_pass=$(openssl rand -base64 12)

set -e

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
public_cert_path=$working_directory/crime-portal-gateway.crt

echo "🚚 Cert '${trusted_cert:? ⚠️ --trusted_cert parameter is required to create keystore}' will be added to the generated keystore"
if [[ -f "$keystore_path" ]];
then
  echo "⚠️ Keystore $keystore_path already exists, delete it to continue."
  echo "👋 Exiting"
  exit 1
fi
keytool -genkey -alias $key_alias -keyalg RSA -keystore $keystore_path  -keysize 2048 -validity $cert_validity -dname "CN=$cert_cn, OU=$cert_ou, O=$cert_o, L=$cert_l, ST=$cert_st, C=$cert_c" -storepass $keystore_pass

echo "✨ New keystore created at '$keystore_path'"
echo "🔑 Saving keystore password to $password_path"
echo -n $keystore_pass > $password_path

echo "🗃 Adding trusted cert '${trusted_cert}' to keystore"
keytool -import -trustcacerts -alias $trusted_alias -file $trusted_cert -keystore $keystore_path -storepass $keystore_pass -noprompt

echo "🎫 Generating public certificate '$public_cert_path'"
keytool -export -alias mgwextdoc -keystore $keystore_path -rfc -file $public_cert_path -storepass $keystore_pass

echo "🎉 Done"
