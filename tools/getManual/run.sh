#!/usr/bin/env bash
#
# Ollama Bash Toolshed - Get the manual page for a command

arguments="$@"
command=$(echo "$arguments" | jq -r '.command')

if [ "${command}" = "null" ]; then
  echo "Error: Please specify command";
  exit
fi

man -P cat "$command"
