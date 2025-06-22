#!/usr/bin/env bash
#
# Ollama Bash Toolshed - calculator with bc

arguments="$@"
input=$(echo "$arguments" | jq -r '.input')

if [ -z "${input}" ]; then
  echo "Error: Please specify match calculation as input";
else
  echo "$input" | bc
fi
