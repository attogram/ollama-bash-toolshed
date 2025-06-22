#!/usr/bin/env bash
#
# Ollama Bash Toolshed
#
# Bash scripts to chat with tool using models. Add new tools to your shed with ease. Runs on Ollama.
#
# Usage:
#  ./ollama-bash-toolshed.sh
#  ./ollama-bash-toolshed.sh modelname
#

NAME="ollama-bash-toolshed"
VERSION="0.18"
URL="https://github.com/attogram/ollama-bash-toolshed"

TOOLS_DIRECTORY="./tools" # no slash at end
OLLAMA_API_URL="http://localhost:11434/api/chat"
DEBUG_MODE="0"

echo; echo "$NAME v$VERSION";

model=""
messages=""
messageCount=0
requestCount=0
toolCount=0
toolDefinitions=""
availableTools=()

PROMPT=$'\e[38;5;24m'$'\e[48;5;0m' # background black, foreground blue
THINKING=$'\e[38;5;241m'$'\e[48;5;0m' # background black, foreground grey
RESET=$'\e[0m' # reset terminal colors

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
  local toolName
  for toolDir in $TOOLS_DIRECTORY/*/; do
    if [ -d "${toolDir}" ]; then
      toolName=$(basename "${toolDir}")
      local definitionFile="${toolDir}definition.json"
      if [ -f "${definitionFile}" ]; then
        if [ -n "$toolDefinitions" ]; then
          toolDefinitions+=","
        fi
        toolDefinitions+="$(cat "$definitionFile")"
        availableTools+=("$toolName")
      fi
      ((toolCount++))
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
  ((messageCount++))
  debug "addMessage # $messageCount: role: $role - content: $message"
}

createRequest() {
    cat <<EOF
{
  "model": "$model",
  "messages": [ ${messages} ],
  "stream": false,
  "think": true,
  "tools": [ ${toolDefinitions} ]
}
EOF
}

sendRequestToAPI() {
  echo "$(createRequest)" | curl -s -X POST "$OLLAMA_API_URL" -H 'Content-Type: application/json' -d @-
}

clearModel() {
  echo "Clearing model session: $model"
  (
    expect \
    -c "spawn ollama run $model" \
    -c "expect \">>> \"" \
    -c 'send -- "/clear\n"' \
    -c "expect \"Cleared session context\"" \
    -c 'send -- "/bye\n"' \
    -c "expect eof" \
    ;
  ) # > /dev/null 2>&1 # Suppress output
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to clear model session: $model" >&2
  fi
}

processErrors() {
    if echo "$response" | jq -e '.error' >/dev/null; then # Check for errors
      local error=$(echo "$response" | jq -r '.error')
      echo "Error: $error"
      return 1
    fi
    return 0 # no errors
}

processToolCall() {
  if echo "$response" | jq -e '.message.tool_calls' >/dev/null; then # Check if response contains tool_calls

    local responseMessageThinking=$(echo "$response" | jq -r '.message.thinking')
    if [ -n "$responseMessageThinking" ]; then
      echo "${THINKING}🤔💭 $responseMessageThinking 💭🤔${RESET}"; echo
    fi

    local responseMessageContent=$(echo "$response" | jq -r '.message.content')
    if [ -n "$responseMessageContent" ]; then
      echo "$responseMessageContent"
    fi

    #debug "Tool calls detected"
    local tool_calls=$(echo "$response" | jq -r '.message.tool_calls[]') # get all tool calls
    while IFS= read -r tool_call; do # Process each tool call
      local function_name=$(echo "$tool_call" | jq -r '.function.name')
      local function_arguments=$(echo "$tool_call" | jq -r '.function.arguments')
      #debug "Calling function: $function_name"
      local result
      if [[ " ${availableTools[*]} " =~ " ${function_name} " ]]; then # If tool is defined
        toolFile="$TOOLS_DIRECTORY/${function_name}/run.sh ${function_arguments}"
        #debug "Running tool: $toolFile"
        echo "[TOOL] ${function_name} ${function_arguments}"; echo
        result="$($toolFile)"
        #debug "Tool result: $result"
        #echo " - Result: ${result}"; echo
      else
        debug "Unknown function: $function_name"
        continue
      fi

      addMessage "assistant" "CALL TOOL $function_name ${function_arguments}" # TODO - better to copy actual assistant response
      addMessage "tool" "$result" # Add tool response to messages

      debug "calling $OLLAMA_API_URL"
      response=$(sendRequestToAPI)
      ((requestCount++))
      debug "tools response: $(echo "$response" | jq -r '.' 2>/dev/null)"

    done < <(echo "$tool_calls" | jq -c '.')
  fi
}

userRunTool() {
  local tool="$1"
  local parameters="$2"
  local paramNames=()
  local paramValues=()

  echo "Running tool: $tool with parameters: $parameters"

  # for every param="value" (or param=value) pair
  while [[ $parameters =~ ([^[:space:]=]+)=((\"[^\"]*\")|([^[:space:]]+)) ]]; do
    key="${BASH_REMATCH[1]}"
    val="${BASH_REMATCH[2]}"
    val="${val%\"}" # remove quotes
    val="${val#\"}"
    paramNames+=("$key")
    paramValues+=("$val")
    parameters="${parameters#*"${BASH_REMATCH[0]}"}" # trim off processed part
  done

  local parametersJson=""
  for i in "${!paramNames[@]}"; do
    #echo "${paramNames[$i]}: ${paramValues[$i]}"
    if [ -n "$parametersJson" ]; then
      parametersJson+=","
    fi
    parametersJson+="\"${paramNames[$i]}\":\"${paramValues[$i]}\""
  done
  parametersJson="{$parametersJson}"
  #echo "parametersJson: $parametersJson"

  local toolFileCall="$TOOLS_DIRECTORY/${tool}/run.sh ${parametersJson}"
  echo; echo "$($toolFileCall)"
}

processUserCommand() {
  firstChar=${prompt:0:1}
  if [ "$firstChar" != "/" ]; then
    return 1 # no user command was processed
  fi
  IFS=' ' read -r -a commandArray <<< "$prompt"
  case ${commandArray[0]} in
    /help)
      echo "Commands:"
      echo "  /list           - get models installed"
      echo "  /load modelName - load the model"
      echo "  /show modelName - show info about model"
      echo "  /tools          - list tools available"
      echo "  /run toolName param1=\"value\" param2=\"value\" - run a tool, with optional parameters"
      echo "  /messages       - list of current messages"
      echo "  /clear          - clear the message and model cache"
      echo "  /quit or /bye   - end the chat"
      echo "  /help           - list of commands"
      ;;
    /quit|/bye)
      echo "Closing the Ollama Bash Toolshed. Bye!"
      exit
      ;;
    /list)
      ollama list
      ;;
    /show)
      ollama show "${commandArray[1]}"
      ;;
    /messages)
      echo "{ \"messages\": [ ${messages} ] }" | jq -r '.messages' 2>/dev/null
      ;;
    /clear)
      echo "Clearing message list"
      messages=""
      messageCount=0
      clearModel
      ;;
    /load)
      local newModel="${commandArray[1]}"
      echo "Loading model: $newModel"
      model="$newModel"
      ;;
    /tools)
      echo "${availableTools[*]}"
      #echo; echo "Tool definitions:"
      #echo "${toolDefinitions}"
      ;;
    /run)
      local tool="${commandArray[1]}"
      if [[ " ${availableTools[*]} " =~ " ${tool} " ]]; then # If tool is defined
        userRunTool "$tool" "${commandArray[*]:2}"
      else
        echo "Error: Tool not in the shed"
      fi
      ;;
    *)
      echo "ERROR: Unknown command: ${commandArray[0]}"
      ;;
  esac
  return 0 # user command was processed
}

chat() {
  local prompt="$1"

  processUserCommand
  if [[ $? = 0 ]]; then # If a user command was processed
    return
  fi

  if [ -z "$model" ]; then
    echo "Error: no model loaded. Use '/list' to get available models.  Use '/load modelName' to load a model."
    return
  fi

  addMessage "user" "$prompt"

  debug "calling $OLLAMA_API_URL"
  #debug "$(createRequest)"
  response=$(sendRequestToAPI)
  ((requestCount++))
  debug "response: $(echo "$response" | jq -r '.' 2>/dev/null)"

  processErrors
  if [[ $? = 1 ]]; then # If there was an error
    return
  fi

  processToolCall

  local responseMessageContent=$(echo "$response" | jq -r '.message.content')
  local responseMessageThinking=$(echo "$response" | jq -r '.message.thinking')

  addMessage "assistant" "$responseMessageContent"

  if [ -n "$responseMessageThinking" ]; then
    echo "${THINKING}🤔💭 $responseMessageThinking 💭🤔${RESET}"; echo
  fi

  echo "$responseMessageContent"
}

checkRequirements() {
  local requirements=(
    "ollama"   # core
    "basename" # core
    "curl"     # core, getWebPageHtml
    "jq"       # core, tools
    "expect"   # core
    "sed"      # core
    "wc"       # core
    "bc"       # core, calculator
    "date"     # getDateTime
    "man"      # getManualPageForCommand
    "lynx"     # getWebPageText
  )
  for requirement in "${requirements[@]}"; do
    check=$(command -v $requirement 2> /dev/null)
    if [ -z "$(command -v $requirement 2> /dev/null)" ]; then
      echo "Requirement ERROR: Requirment not installed: $requirement"
    else 
      debug "Requirement OK: $requirement"
    fi
  done
}

checkRequirements

parseCommandLine "$@"

if [ -z "$model" ]; then
  echo; echo "No model is loaded. Available models:"; echo
  ollama list
  echo; echo "To load a model: /load modelName"
fi

getTools
echo; echo "Tools: ${availableTools[*]}";
echo; echo "Use /help for commands. Use /quit or Press Ctrl+C to exit."

while true; do
    modelName="$model"
    if [ -z "$modelName" ]; then
      modelName="no model loaded"
    fi
    echo; echo -n "$PROMPT$NAME ($modelName) ($toolCount tools)"
    echo -n " [$requestCount requests]"
    messagesWordCount=$(echo "$messages" | wc -w)
    tokenEstimate=$(echo "$messagesWordCount * 0.75" | bc)
    echo -n " [$messageCount messages | ~$tokenEstimate tokens | $messagesWordCount words | ${#messages} chars]"
    echo; echo -n ">>>${RESET} "
    read -r prompt
    echo
    chat "$prompt"
done
