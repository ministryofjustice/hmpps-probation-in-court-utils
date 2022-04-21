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
working_directory=~/temp/$namespace
public_cert_path=$working_directory/crime-portal-gateway.crt

keytool -printcert -v -file $public_cert_path
