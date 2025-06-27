#!/usr/bin/env bash
#
# ollama capable
#
# A tool for the Ollama Bash Toolshed

ability="$1"

if [ -z "$ability" ]; then
  echo "ERROR: 'ability' parameter missing or empty"
  exit
fi

while IFS= read -r line; do
  model="${line%% *}"
  if [[ "$model" == "NAME" ]]; then continue; fi
  capabilities="$(echo "$(./show.sh "$model")" | jq -c '.capabilities')"
  case "$capabilities" in
    *"\"$ability\""*)
      echo -n "${model}"; echo -n $'\t'; echo "$capabilities"
  esac
done <<< "$(ollama list)"
