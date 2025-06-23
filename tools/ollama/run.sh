#!/usr/bin/env bash
#
# ollama
#
# A tool for the Ollama Bash Toolshed

arguments="$@"
action=$(echo "$arguments" | jq -r '.action')

if [ "${action}" = "null" ]; then
  echo "Error: Please specify an action";
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
