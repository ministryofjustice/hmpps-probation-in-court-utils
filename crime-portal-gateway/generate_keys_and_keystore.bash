#!/bin/bash
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
keytool -genkey -alias $key_alias -keyalg RSA -keystore $keystore_path  -keysize 2048 -validity $cert_validity -dname "CN=$cert_cn, OU=$cert_ou, O=$cert_o, L=$cert_l, ST=$cert_st, C=$cert_c" -storepass $keystore_pass

echo "✨ New keystore created at '$keystore_path'"
echo "🔑 Saving keystore password to $password_path"
echo -n $keystore_pass > $password_path

echo "🗃 Adding trusted cert '${trusted_cert}' to keystore"
keytool -import -trustcacerts -alias $trusted_alias -file $trusted_cert -keystore $keystore_path -storepass $keystore_pass -noprompt

echo "🎫 Generating public certificate '$public_cert_path'"
keytool -export -alias mgwextdoc -keystore $keystore_path -rfc -file $public_cert_path -storepass $keystore_pass

echo "🎉 Done"
