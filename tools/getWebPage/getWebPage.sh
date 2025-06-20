#!/usr/bin/env bash
#
# Ollama Bash Toolshed - Get a web page

arguments="$@"
url=$(echo "$arguments" | jq -r '.url')

userAgent="ollama-bash-toolshed"

if [ -z "${url}" ]; then
  echo "Error: Please specify full URL of the web page";
else
  curl --user-agent "$userAgent" --silent "$url"
fi
