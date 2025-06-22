#!/usr/bin/env bash
#
# Ollama Bash Toolshed - Get Web Page Text

arguments="$@"
url=$(echo "$arguments" | jq -r '.url')

userAgent="ollama-bash-toolshed (lynx)"

if [ -z "${url}" ]; then
  echo "Error: Please specify full URL of the web page";
else
  lynx --dump -useragent="$userAgent" "$url"
fi
