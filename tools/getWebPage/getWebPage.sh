#!/usr/bin/env bash

arguments="$@"
#echo "DEBUG: arguments: $arguments"

url=$(echo "$arguments" | jq -r '.url')
#echo "DEBUG: url: $url"

userAgent="ollama-bash-toolshed"

if [ -z "${url}" ]; then
  echo "Error: Please specify full URL of the web page";
else
  curl --user-agent "$userAgent" --silent "$url"
fi
