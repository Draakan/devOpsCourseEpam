#!/bin/bash

if [ $# -eq 0  ]
then
 echo "No directory was provided!"
 exit 1
fi

traverse() {
 local directory="$1"
 local num_files=$(ls -1 "$directory" | wc -l)
 echo "$directory: $num_files"

 for file in "$directory"/*
 do
  if [ -d "$file" ]
  then
   traverse "$file"
  fi
 done
}

for directory in "$@"
do
 traverse "$directory"
done
