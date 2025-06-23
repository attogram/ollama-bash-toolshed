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
VERSION="0.22"
URL="https://github.com/attogram/ollama-bash-toolshed"

TOOLS_DIRECTORY="./tools" # no slash at end
OLLAMA_API_URL="http://localhost:11434/api/chat"
DEBUG_MODE="0"

echo; echo "$NAME v$VERSION";

model=""
messages=""
messageCount=0
request=""
requestCount=0
response=""
availableTools=()
toolCount=0
toolDefinitions=""

configs=(
  "tools:on"
  "think:off"
  "verbose:off"
)

setColorScheme() {
  PROMPT=$'\e[38;5;24m'$'\e[48;5;0m' # background black, foreground blue
  THINKING=$'\e[38;5;241m'$'\e[48;5;0m' # background black, foreground grey
  RESET=$'\e[0m' # reset terminal colors
}

debug() {
  if [ "$DEBUG_MODE" == "1" ]; then
    echo -e "[DEBUG] $1"
  fi
}

debugJson() {
  if [ "$DEBUG_MODE" == "1" ]; then
    echo "$1" | jq -r '.' 2>/dev/null
  fi
}

getConfig() {
  local configName="$1"
  for config in "${configs[@]}"; do
    if [[ "${config%%:*}" == "$configName" ]]; then
      echo "${config#*:}"
      break
    fi
  done
}

setConfig() {
  local configName="$1"
  local configValue="$2"
  local newConfigs=()
  for config in "${configs[@]}"; do
    name="${config%%:*}"
    value="${config#*:}"
    if [[ "$name" == "$configName" ]]; then
      value=${commandArray[2]}
      echo "$name: $value"
    fi
    # set var $nameConfig to $value
    eval ${name}Config=\$value
    newConfigs+=("$name:$value")
  done
  configs=("${newConfigs[@]}")
  setConfigs
}

setConfigs() {
  for config in "${configs[@]}"; do
    name="${config%%:*}"
    value="${config#*:}"
    # set $nameConfig to $value
    eval ${name}Config=\$value
    case $name in
      tools)
        getTools
        ;;
      verbose)
        if [[ "$value" == "on" ]]; then
          DEBUG_MODE=1
        else
          DEBUG_MODE=0
        fi
        ;;
    esac
  done
}

parseCommandLine() {
  model="$1"
}

getTools() {
  availableTools=()
  toolDefinitions=""
  if [[ "$toolsConfig" != "on" ]]; then
    toolCount=0
    return
  fi

  local toolDir
  local toolName
  availableTools=()
  for toolDir in $TOOLS_DIRECTORY/*/; do
    if [ -d "${toolDir}" ]; then
      toolName=$(basename "${toolDir}")
      local definitionFile="${toolDir}/definition.json"
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
  debug "addMessage #$messageCount: role: $role - content: $message"
}

createRequest() {
    echo "{\"model\": \"$model\", \"messages\": [ ${messages} ], \"stream\": false"
    if [ "$thinkConfig" == "on" ]; then
      echo ", \"think\": true"
    fi
    if [ "$toolsConfig" == "on" ]; then
      echo ", \"tools\": [ ${toolDefinitions} ]"
    fi
    echo "}"
}

sendRequestToAPI() {
  echo "$(createRequest)" | curl -s -X POST "$OLLAMA_API_URL" -H 'Content-Type: application/json' -d @-
}

sendRequest() {
  debug "request:"
  debugJson "$(createRequest)"
  ((requestCount++))
  debug "POST to $OLLAMA_API_URL"
  response=$(sendRequestToAPI)
  debug "response:"
  debugJson "$response"
}

clearModel() {
  if [ -z "$model" ]; then
    return
  fi
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
    echo "$response" | jq -r '.error' 2>/dev/null
    return 1
  fi
  return 0 # no errors
}

processToolCall() {
  if echo "$response" | jq -e '.message.tool_calls' >/dev/null; then # Check if response contains tool_calls
    showThinking
    local responseMessageContent=$(echo "$response" | jq -r '.message.content' 2>/dev/null)
    if [ -n "$responseMessageContent" ]; then
      echo "$responseMessageContent"
    fi
    local tool_calls=$(echo "$response" | jq -r '.message.tool_calls[]' 2>/dev/null) # get all tool calls
    while IFS= read -r tool_call; do # Process each tool call
      local function=$(echo "$tool_call" | jq -r '.function' 2>/dev/null)
      local function_name=$(echo "$tool_call" | jq -r '.function.name' 2>/dev/null)
      local function_arguments=$(echo "$tool_call" | jq -r '.function.arguments' 2>/dev/null)
      debug "processToolCall: Calling function: $function_name"
      local toolResult
      if [[ " ${availableTools[*]} " =~ " ${function_name} " ]]; then # If tool is defined
        toolFile="$TOOLS_DIRECTORY/${function_name}/run.sh ${function_arguments}"
        debug "processToolCall: Running toolFile: $toolFile"
        echo -n "[TOOL] "
        echo "$function" | jq -r '.' 2>/dev/null
        toolResult="$($toolFile)"
        echo "[TOOL] result: $(echo "$toolResult" | wc -c | sed 's/ //g') characters, $(echo "$toolResult" | wc -l | sed 's/ //g') lines"
        echo "[TOOL] result: $(echo "$toolResult" | head -1)"; echo
        debug "processToolCall: Tool result: $toolResult"
      else
        debug "processToolCall: Unknown function: $function_name"
        continue
      fi
      #debug "processToolCall: addMessage assistant CALL TOOL"
      #addMessage "assistant" "$function" # TODO - better to copy actual assistant response
      debug "processToolCall: addMessage tool result..."
      addMessage "tool" "$toolResult" # Add tool response to messages
      debug "processToolCall: sendRequest..."
      sendRequest
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
      echo "  /list           - list of models installed"
      echo "  /load modelName - load model"
      echo "  /info modelName - info about model"
      echo "  /pull modelName - pull new model"
      echo "  /tools          - list tools available"
      echo "  /tools toolName - show tool definition"
      echo "  /run toolName param1=\"value\" param2=\"value\" - run a tool, with optional parameters"
      echo "  /messages       - list of current messages"
      echo "  /clear          - clear the message and model cache"
      echo "  /config         - view all configs (tools, think, verbose)"
      echo "  /config name    - view a config"
      echo "  /config name value - set a config to new value"
      echo "  /quit or /bye   - end the chat"
      echo "  /help           - list of all commands"
      ;;
    /config)
      if [ -n "${commandArray[2]}" ]; then
        setConfig "${commandArray[1]}" "${commandArray[2]}"
      elif [ -n "${commandArray[1]}" ]; then
        echo -n "${commandArray[1]}: "
        getConfig "${commandArray[1]}"
      else
        for config in "${configs[@]}"; do
          echo "${config%%:*}: ${config#*:}"
        done
      fi
      ;;
    /quit|/bye)
      echo "Closing the Ollama Bash Toolshed. Bye!"; echo
      exit
      ;;
    /list)
      ollama list
      ;;
    /show)
      ollama show "${commandArray[1]}"
      ;;
    /pull)
      ollama pull "${commandArray[1]}"
      ;;
    /messages)
      echo "{\"messages\":[${messages}]}" | jq -r '.messages' 2>/dev/null
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
      if [ -n "${commandArray[1]}" ]; then
        cat "$TOOLS_DIRECTORY/${commandArray[1]}/definition.json" | jq -r '.' 2>/dev/null
      else
        echo "${availableTools[*]}"
      fi
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

showThinking() {
  if [[ "$thinkConfig" != "on" ]]; then
    return
  fi
  local responseMessageThinking=$(echo "$response" | jq -r '.message.thinking' 2>/dev/null)
  if [ -n "$responseMessageThinking" ]; then
    echo "${THINKING}🤔💭 $responseMessageThinking 💭🤔${RESET}"; echo
  fi
}

chat() {
  local prompt="$1"
  processUserCommand
  if [[ $? = 0 ]]; then # If a user command was processed
    return
  fi
  if [ -z "$model" ]; then
    echo "chat error: no model loaded. Use '/list' to get available models.  Use '/load modelName' to load a model."
    return
  fi
  addMessage "user" "$prompt"
  sendRequest
  processErrors
  if [[ $? = 1 ]]; then # If there was an error
    return
  fi
  processToolCall
  showThinking
  responseMessageContent="$(echo "$response" | jq -r '.message.content' 2>/dev/null)"
  addMessage "assistant" "$responseMessageContent"
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
    "head"     # core
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

setConfigs
setColorScheme
checkRequirements
parseCommandLine "$@"

if [ -z "$model" ]; then
  echo; echo "⚠️ No model loaded."
  echo "To view available modules use: /list"
  echo "To load a model use: /load modelName"
fi

if [ -n $string1 "$availableTools" ]; then
  echo; echo "Tools: ${availableTools[*]}";
fi
echo; echo "Use /help for commands. Use /quit or Press Ctrl+C to exit."

while true; do
    echo
    echo -n "$PROMPT$NAME (${model:-no model})"
    echo -n " ($toolCount tools)"
    echo -n " [$requestCount requests]"
    echo -n " [$messageCount messages]"
    echo; echo -n ">>>${RESET} "
    read -r prompt
    echo
    chat "$prompt"
done
