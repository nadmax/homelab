#!/usr/bin/env bash

# https://unix.stackexchange.com/questions/285924/how-to-compare-a-programs-version-in-a-shell-script

function version_compare () {
  function sub_ver () {
    # local len=${#1}
    temp=${1%%"."*} && indexOf=$(echo ${1%%"."*} | echo ${#temp})
    echo -e "${1:0:indexOf}"
  }
  function cut_dot () {
    local offset=${#1}
    local length=${#2}
    echo -e "${2:((++offset)):length}"
  }
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "=" && exit 0
  fi
  local v1="$(echo -e "${1}" | tr -d '[[:space:]]')"
  local v2="$(echo -e "${2}" | tr -d '[[:space:]]')"
  local v1_sub="$(sub_ver $v1)"
  local v2_sub="$(sub_ver $v2)"
  if (( v1_sub > v2_sub )); then
    echo ">"
  elif (( v1_sub < v2_sub )); then
    echo "<"
  else
    version_compare "$(cut_dot $v1_sub $v1)" "$(cut_dot $v2_sub $v2)"
  fi
}

### Usage:

# version_compare "1.9.10" "1.8.4"
# Output: <
