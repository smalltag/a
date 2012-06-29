#!/bin/bash
PATH+=":."
cache="$(cygpath -F28)/*/*/Profiles/*/Cache/_CACHE_0*"
p="plugin-container.exe"

pid(){
  ps -W | grep "$1" | cut -c-9
}

binparse(){
  cat $1 | grep -azm1 "$2" | cut -d "$3" -f "$4"
}

red(){
  printf "\e[1;31m%s\e[m\n" "$1"
}

# Clear Firefox cache
pid "$p" | xargs /bin/kill -f
: | tee $cache
red 'Press enter after video starts'; read
red 'Printing results'

# Script
read script < <(which AdobeHDS.php | cygpath -mf-)

# Auth
read auth < <(binparse "$cache" "Seg.*?" "?" "2")

# Manifest
read manifest < <(binparse "$cache" "f4m?" "/" "3-")

# Run
set -x
php "$script" --auth "$auth" --manifest "$manifest"
