#!/usr/bin/env bash
#
# Ollama Manager
#
# A tool for the Ollama Bash Toolshed

arguments="$@"
action=$(echo "$arguments" | jq -r '.action')

if [ -z "${action}" ]; then
  echo "Error: Please specify a action";
  exit
fi

case "$action" in
  ollama_version)
    ollama --version
    ;;
  models_list)
    ollama list
    ;;
  model_info)
    model=$(echo "$arguments" | jq -r '.model')
    ollama show "$model"
    ;;
  *)
    echo "Error: Unknown action"
    ;;
esac
