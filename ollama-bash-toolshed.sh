#!/usr/bin/env bash
#
# Ollama Bash Toolshed
#
# For small models that support tool usage see: <https://github.com/attogram/small-models/tree/main#tool-usage>
#

NAME="ollama-bash-toolshed"
VERSION="0.3"
URL="https://github.com/attogram/ollama-bash-toolshed"
OLLAMA_API_URL="http://localhost:11434/api/chat"
DEBUG_MODE="0"

echo; echo "$NAME v$VERSION"; echo

model=""
messages=""
toolDefinitions=""
availableTools=()

debug() {
  if [ "$DEBUG_MODE" != "1" ]; then
    return
  fi
  echo -e "[DEBUG] $1"
}

parseCommandLine() {
  model="$1"
}

getTools() {
  local toolDir
  for toolDir in ./tools/*/; do
    if [ -d "${toolDir}" ]; then
      local toolName
      toolName=$(basename "${toolDir}")
      local jsonFile="${toolDir}${toolName}.json"
      if [ -f "${jsonFile}" ]; then
        if [ -n "$toolDefinitions" ]; then
          toolDefinitions+=","
        fi
        toolDefinitions+="$(cat "$jsonFile")"
        availableTools+=("$toolName")
      fi
    fi
  done
  #debug "toolDefinitions: ${toolDefinitions}"
  #debug "availableTools: ${availableTools[*]}"
}

safeJson() {
  jq -Rn --arg str "$1" '$str'
}

addMessage() {
  local role="$1"
  local message="$2"
  if [ -n "$messages" ]; then
    messages+=","
  fi
  message=$(safeJson "$message")
  messages+="{\"role\":\"$role\",\"content\":$message}"
  debug "addMessage: role: $role - content: $message"
}

createRequest() {
    cat <<EOF
{
  "model": "$model",
  "messages": [ ${messages} ],
  "stream": false,
  "tools": [ ${toolDefinitions} ]
}
EOF
}

sendRequestToAPI() {
  curl -s -X POST "$OLLAMA_API_URL" -H 'Content-Type: application/json' -d "$(createRequest)"
}

processErrors() {
    if echo "$response" | jq -e '.error' >/dev/null; then # Check for errors
      local error=$(echo "$response" | jq -r '.error')
      echo "Error: $error"
      return 1
    fi
    return 0
}

processToolCall() {
  if echo "$response" | jq -e '.message.tool_calls' >/dev/null; then # Check if response contains tool_calls
    #debug "Tool calls detected"
    local tool_calls=$(echo "$response" | jq -r '.message.tool_calls[]') # get all tool calls
    while IFS= read -r tool_call; do # Process each tool call
      local function_name=$(echo "$tool_call" | jq -r '.function.name')
      local function_arguments=$(echo "$tool_call" | jq -r '.function.arguments')
      #debug "Calling function: $function_name"
      local result
      if [[ " ${availableTools[*]} " =~ " ${function_name} " ]]; then # If tool is defined
        toolFile="./tools/${function_name}/${function_name}.sh ${function_arguments}"
        #debug "Running tool: $toolFile"
        echo "[TOOL] ${function_name} ${function_arguments}"; echo
        result="$($toolFile)"
        debug "Tool result: $result"
        #echo " - Result: ${result}"; echo
      else
        debug "Unknown function: $function_name"
        continue
      fi

      addMessage "assistant" "CALLING TOOL $function_name ${function_arguments}" # TODO - better to copy actual assistant response
      addMessage "tool" "$result" # Add tool response to messages
      debug "tools: about to send to API: createRequest: $(createRequest)"
      response=$(sendRequestToAPI)
      debug "tools response: $(echo "$response" | jq -r '.' 2>/dev/null)"

    done < <(echo "$tool_calls" | jq -c '.')
  fi
}

chat() {
  local prompt="$1"

  addMessage "user" "$prompt"
  #debug "Calling $OLLAMA_API_URL"
  debug "chat: about to send to API: createRequest: $(createRequest)"
  response=$(sendRequestToAPI)
  debug "1st response: $(echo "$response" | jq -r '.' 2>/dev/null)"

  processErrors
  if [[ $? != 0 ]]; then
    return
  fi

  processToolCall
  debug "2nd response: $(echo "$response" | jq -r '.' 2>/dev/null)"
  responseMessageContent=$(echo "$response" | jq -r '.message.content')
  addMessage "assistant" "$responseMessageContent"
  #debug "Assistant Response:\n"
  echo "$responseMessageContent"
}

parseCommandLine "$@"
if [ -z "${model}" ]; then
  echo "Error: no model. Usage: ./${0##*/} \"modelname\"";
  echo; echo "Your local models:"
  ollama list
  exit 1
fi

echo "Model: $model"

getTools
echo "Available Tools: ${availableTools[*]}";

echo "Press Ctrl+C to exit"

while true; do
    echo; echo -n "Prompt: "
    read -r prompt
    echo
    chat "$prompt"
done
