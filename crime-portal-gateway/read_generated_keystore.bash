#!/bin/bash

# 📄 Decrypts and reads a keystore generated locally by one of the other scripts in this folder


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
keystore_path=$working_directory/crime-portal-gateway-jks.key
password_path=$keystore_path.pwd

keytool -list -v -keystore ~/temp/$namespace/crime-portal-gateway-jks.key -storepass $(cat $password_path)
