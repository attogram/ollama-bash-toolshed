#!/usr/bin/env bash
#
# Ollama Bash Toolshed - Get info about an ollama model.  Model info (architecture, parameters, context length, embedding length, quantization), Capabilities, Parameters, License, etc

arguments="$@"
model=$(echo "$arguments" | jq -r '.model')

if [ -z "${model}" ]; then
  echo "Error: Please specify a model";
else
  ollama show "$model"
fi
