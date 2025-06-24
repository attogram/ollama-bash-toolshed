#!/usr/bin/env bash
#
# ollama
#
# A tool for the Ollama Bash Toolshed

arguments="$@"
action=$(echo "$arguments" | jq -r '.action')
if [ "${action}" = "null" ]; then
  echo "ERROR: 'action' parameter missing or empty";
  exit
fi

getModel() {
  model=$(echo "$arguments" | jq -r '.model')
  if [[ "$model" == "null" ]]; then
    echo "ERROR: 'model' parameter missing or empty"
    exit
  fi
  echo "$model"
}

getMessage() {
  message=$(echo "$arguments" | jq -r '.message')
  if [[ "$message" == "null" ]]; then
    echo "ERROR: 'message' parameter missing or empty"
    exit
  fi
  echo "$message"
}

case "$action" in
  list)
    ollama list
    ;;
  ps)
    ollama ps
    ;;
  run)
    ollama run "$(getModel)" "$(getMessage)"
    ;;
  show)
    ollama show "$(getModel)"
    ;;
  stop)
    ollama stop "$(getModel)"
    ;;
  version)
    ollama --version
    ;;
  *)
    echo "ERROR: Unknown action"
    ;;
esac
