#!/usr/bin/env bash
#
# Ollama Bash Toolshed - Ollama Manager

arguments="$@"
action=$(echo "$arguments" | jq -r '.action')

if [ -z "${action}" ]; then
  echo "Error: Please specify a action";
  exit
fi

echo "IN DEV: Action: $action"