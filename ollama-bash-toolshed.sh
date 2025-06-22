#!/usr/bin/env bash
#
# Ollama Bash Toolshed
#
# Bash scripts to chat with tool using models. Add new tools to your shed with ease. Runs on Ollama.
#
# Usage:
#  ./ollama-bash-toolshed.sh "modelname"
#

NAME="ollama-bash-toolshed"
VERSION="0.11"
URL="https://github.com/attogram/ollama-bash-toolshed"
OLLAMA_API_URL="http://localhost:11434/api/chat"
DEBUG_MODE="0"

echo; echo "$NAME v$VERSION";

model=""
messages=""
messageCount=0
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
  ((messageCount++))
  debug "addMessage # $messageCount: role: $role - content: $message"
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

processUserCommand() {
  firstChar=${prompt:0:1}
  if [ "$firstChar" != "/" ]; then
    return 1 # no user command was processed
  fi

  IFS=' ' read -r -a commandArray <<< "$prompt"

  case ${commandArray[0]} in

    /help)
      echo "Ollama Bash Toolshed User Commands:"
      echo "  /list - get models installed"
      echo "  /load <modelName> - load the model"
      echo "  /show <modelName> - show info about model"
      echo "  /clear - clear the message cache"
      echo "  /tools - list tools available"
      echo "  /run <toolName> \"parameterName=parameterValue\" - run a tool"
      echo "  /quit or /bye - end the chat"
      echo "  /help - list of commands"
      ;;
    /quit|/bye)
      echo "Stopping the Ollama Bash Toolshed. Bye!"
      exit
      ;;
    /list)
      ollama list
      ;;
    /show)
      ollama show "${commandArray[1]}"
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
      echo "Tools available: ${availableTools[*]}"
      echo; echo "Tool definitions:"
      echo "${toolDefinitions}"
      ;;
    /run)
      local tool="${commandArray[1]}"
      if [[ " ${availableTools[*]} " =~ " ${tool} " ]]; then # If tool is defined
        echo "Running tool: $tool"
        local parameters="${commandArray[2]}"
        IFS='=' read -r -a parametersArray <<< "$parameters"
        #  strip quotes from start and end
        parametersArray[0]=$(sed -e 's/^"//' -e 's/"$//' <<<"${parametersArray[0]}")
        parametersArray[1]=$(sed -e 's/^"//' -e 's/"$//' <<<"${parametersArray[1]}")
        local parametersJson="{\"${parametersArray[0]}\": \"${parametersArray[1]}\"}"
        echo "Parameters: $parametersJson"
        local toolFileCall="./tools/${tool}/${tool}.sh ${parametersJson}"
        echo; echo "$($toolFileCall)"
      else
        echo "Error: tool not in the shed"
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

  addMessage "user" "$prompt"
  #debug "Calling $OLLAMA_API_URL"
  debug "chat: about to send to API: createRequest: $(createRequest)"
  response=$(sendRequestToAPI)
  #debug "1st response: $(echo "$response" | jq -r '.' 2>/dev/null)"

  processErrors
  if [[ $? = 1 ]]; then # If there was an error
    return
  fi

  processToolCall
  #debug "2nd response: $(echo "$response" | jq -r '.' 2>/dev/null)"
  responseMessageContent=$(echo "$response" | jq -r '.message.content')
  addMessage "assistant" "$responseMessageContent"
  #debug "Assistant Response:\n"
  echo "$responseMessageContent"
}

checkRequirements() {
  local requirements=(
    "ollama --version"   # core
    "basename --version" # core
    "curl --version"     # core, getWebPageHtml
    "jq --version"       # core, tools
    "expect -v"          # core
    "sed --version"      # core
    "wc --version"       # core
    "bc --version"       # core, calculator
    "date --version"     # getDateTime
    "man -P cat man"     # getManualPageForCommand
    "lynx --version"     # getWebPageText
  )
  local check=""
  local cmd=""
  for requirement in "${requirements[@]}"; do
    set -- $requirement
    cmd="$1" # get first word
    check=$($requirement 2> /dev/null)
    if [ -z "$check" ]; then
      echo "Requirement ERROR: $cmd not installed."
    else 
      debug "Requirement OK: $cmd installed"
    fi
  done
}

checkRequirements

parseCommandLine "$@"
if [ -z "${model}" ]; then
  echo "Error: no model. Usage: ./${0##*/} \"modelname\"";
  echo; echo "Your local models:"
  ollama list
  echo "type /load modelName to load a model"
  #exit 1
fi

echo; echo "Model: $model"
getTools
echo; echo "Tools: ${availableTools[*]}";
echo; echo "type /help for user commands.  Press Ctrl+C to exit"

while true; do
    messagesWordCount=$(echo "$messages" | wc -w)
    tokenEstimate=$(echo "$messagesWordCount * 0.75" | bc)
    echo; echo "($model) [$messageCount messages] [~$tokenEstimate tokens] [$messagesWordCount words] [${#messages} characters]"
    echo -n "Prompt: "
    read -r prompt
    echo
    chat "$prompt"
done
