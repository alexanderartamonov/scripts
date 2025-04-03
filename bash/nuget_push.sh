#!/bin/bash

directory="./"
suffix="nupkg"

browsefolders ()
  for i in "$1"/*;
  do
    echo "dir :$directory"
    echo "filename: $i"
    #    echo ${i#*.}
    extension=`echo "$i" | cut -d'.' -f2`
    echo "extension $extension"
    if     [ -f "$i" ]; then

        if [ $extension == $suffix ]; then
            echo "$i ends with $in"

        else
            echo "$i does NOT end with $in"
        fi
    elif [ -d "$i" ]; then
    browsefolders "$i"
    fi
  done

browsefolders  "$directory"

mkdir tempdir
find ./ -name '*.nupkg' -exec cp -prv '{}' './tempdir' ';'
for file in ./tempdir/*
do
  cmd [option] "$file" >> results.out
done