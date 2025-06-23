#!/usr/bin/env bash
#
# webpage - Get a web page from the internet
#
# A tool for the Ollama Bash Toolshed

arguments="$@"

url=$(echo "$arguments" | jq -r '.url')
if [ "${url}" == "null" ]; then
  echo "Error: Please specify URL of the web page";
  exit
fi

format=$(echo "$arguments" | jq -r '.format')
if [ "${format}" = "null" ]; then
  format="text" # default format
fi

case "$format" in
  text)
    userAgent="ollama-bash-toolshed (lynx)"
    lynx --dump -useragent="$userAgent" "$url"
    ;;
  raw)
    userAgent="ollama-bash-toolshed (curl)"
    curl --user-agent "$userAgent" --silent "$url"
    ;;
  *)
    echo "Error: Unknown format"
    ;;
esac
