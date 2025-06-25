#!/usr/bin/env bash
#
# ollama show
#
# A tool for the Ollama Bash Toolshed
#
# https://github.com/ollama/ollama/blob/main/docs/api.md#show-model-information

model="$1"
if [ -z "$model" ]; then
  echo "ERROR: 'model' parameter missing or empty"
  exit
fi

curl -s -X POST "http://localhost:11434/api/show" -H 'Content-Type: application/json' -d "{\"model\": \"$model\"}"
