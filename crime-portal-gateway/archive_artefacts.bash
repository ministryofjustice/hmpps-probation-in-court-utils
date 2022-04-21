#!/bin/bash

# 📄 Moves all files out of the common working directory for a namespace and into a timestamped sub folder


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

archive_dir=$working_directory/$(date "+%Y-%m-%dT%H-%M-%S")
mkdir $archive_dir
cp $working_directory/* $archive_dir
rm $working_directory/*
