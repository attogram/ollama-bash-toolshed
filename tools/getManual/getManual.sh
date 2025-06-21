#!/usr/bin/env bash
#
# Ollama Bash Toolshed - Get the manual page for a command

arguments="$@"
command=$(echo "$arguments" | jq -r '.command')

if [ -z "${command}" ]; then
  echo "Error: Please specify command";
else
  man -P cat "$command"
fi
