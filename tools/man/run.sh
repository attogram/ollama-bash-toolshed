#!/usr/bin/env bash
#
# man - Get the manual page for a command
#
# A tool for the Ollama Bash Toolshed

arguments="$@"
command=$(echo "$arguments" | jq -r '.command')

if [ "${command}" = "null" ]; then
  echo "Error: Please specify command";
  exit
fi

man -P cat "$command"
