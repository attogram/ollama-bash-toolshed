#!/usr/bin/env bash
#
# ollama capabilities 
#
# A tool for the Ollama Bash Toolshed

model="$1"

if [ -z "$model" ]; then
  while IFS= read -r line; do
    model="${line%% *}"
    if [[ "$model" == "NAME" ]]; then continue; fi
    echo -n "${model}"
    echo -n $'\t'
    echo "$(echo "$(./show.sh "$model")" | jq -c '.capabilities')"
  done <<< "$(ollama list)"
  exit
fi

echo "$(echo "$(./show.sh "$model")" | jq -c '.capabilities')"
