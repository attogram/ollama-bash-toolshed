# Ollama Manager

**ollamaManager** - A tool for the [Ollama Bash Toolshed](../../).

# Example running locally

```/run ollamaManager action=ollama_version```

```/run ollamaManager action=models_list```

```/run ollamaManager action=model_info model=qwen3:0.6b```

# Example model usage

```
ollama-bash-toolshed (qwen3:0.6b) (6 tools) [0 requests] [0 messages]
>>> what version of ollama am I running?

🤔💭 Okay, the user is asking about their Ollama version. Let me check the tools available. There's a function called ollamaManager that can get the version. The parameters require an action enum with options like models_list, model_info, or ollama_version. Since the user wants their current version, the action should be 'ollama_version'. The model parameter is optional here, so I don't need it. Just call the function with action set to ollama_version. No need to mention other functions since the user's query is specifically about their version. 💭🤔

[TOOL] ollamaManager {
  "action": "ollama_version"
}

🤔💭 Okay, the user is asking about their current Ollama version. I need to check if there's a function available for that. Looking at the tools provided, there's the ollamaManager function which can retrieve the version. The parameters require an action enum with 'ollama_version'. So I should call that function with the action set to 'ollama_version'. No other parameters are needed since the user didn't specify a model. Just make sure to format the tool call correctly in JSON within the XML tags. 💭🤔

The current version of Ollama is 0.9.2.

ollama-bash-toolshed (qwen3:0.6b) (6 tools) [2 requests] [4 messages]
>>> /messages

[
  {
    "role": "user",
    "content": "what version of ollama am I running?"
  },
  {
    "role": "assistant",
    "content": "CALL TOOL ollamaManager {\n  \"action\": \"ollama_version\"\n}"
  },
  {
    "role": "tool",
    "content": "ollama version is 0.9.2"
  },
  {
    "role": "assistant",
    "content": "The current version of Ollama is 0.9.2."
  }
]
```
# Parameters

- ```action``` (required)
- ```model``` (required for action=model_info)

# Requirements

- ```ollama``` command
