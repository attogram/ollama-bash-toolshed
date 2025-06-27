# Ollama Bash Toolshed

![Logo](docs/logo/logo.500x250.jpg)

Bash scripts to chat with tool using models. Add new tools to your shed with ease. Runs on Ollama.

## Usage

Run the toolshed:
  ```
  ./ollama-bash-toolshed.sh
  ```
  * This will start the toolshed with no model loaded
    * use ```/list``` to get available models
    * use ```/run modelName``` to load a model

Run the toolshed with a specific model:
  ```
  ./ollama-bash-toolshed.sh "modelname"
  ```

* For models with tools capabilities:
  * See the [ollama.com Tools models](https://ollama.com/search?c=tools) list.
  * See the [small models for tool usage](https://github.com/attogram/small-models/tree/main#tool-usage) list.

## Tools in the shed

* [calculator](tools/calculator) - Perform any standard math calculation (using bc input format)
* [datetime](tools/datetime) - Get the current date and time
* [man](tools/man) - Read command manuals
* [ollama](tools/ollama) - Interact with the Ollama application (list, ps, run, show, stop, version)
* [webpage](tools/webpage) - Get a web page, in format 'text' or 'raw' (defaults to 'text') ('raw' for HTML source)

## User commands

```
Model Commands:
  /list            - List models
  /ps              - List running models
  /pull modelName  - Pull new model
  /run modelName   - Run a model
  /show            - Current model info
  /show modelName  - Model info
  /stop modelName  - Stop a running model

Tool Commands:
  /tools           - list tools available
  /instructions    - list instructions for all tools
  /tool toolName   - show tool definition
  /exec toolName param1="value" param2="value" - run a tool, with optional parameters

System Commands:
  /multi             - enter multi-line prompt
  /messages          - list of current messages
  /system            - show system prompt
  /clear             - clear the message and model cache
  /config            - view all configs (tools, think, verbose)
  /config name       - view a config
  /config name value - set a config to new value
  /quit or /bye      - end the chat
  /help              - list of all commands
```

### Configs

* ```tools``` - [on/off] - use tools
* ```think``` - [on/off] - split out thinking from message content
* ```verbose``` - [on/off] - verbose debug messages

To use a model without tools capability: /config tools off

To use a model with thinking capability: /config think on

### Run tools manually

To run tools manually, use the ```/exec``` command.

To run a tool with no parameters: ```/exec toolName```

to run a tool with parameters: ```/exec toolName param1="value" param2="value"``` ...

Examples: 
* ```/exec calculator input="1 + 2"```
* ```/exec man command=wc```
* ```/exec webpage url="https://ollama.com/search?c=tools"```
* ```/exec webpage url="https://www.example.com" format=raw```

## Add a new tool

Read about the [tools setup](tools/README.md).

To add a new tool:

- Give your tool a name.
  - Example: ```weather```
- create a subdirectory in ```tools/``` directory. The directory name MUST be your tool name.
  - Example: ```tools/weather/```
- create a JSON tool definition file.
  - Example: ```tools/weather/definition.json```
- create a tool instructions file
  - Example: ```tools/weather/instructions.txt```
- create a bash script to run the tool. 
  - Example: ```tools/weather/run.sh```
- chmod your bash script. 
  - Example: ```chmod +x tools/weather/run.sh```
- re-run ```./ollama-bash-toolshed.sh``` to use your new tool.

## Common errors

Error: ```no model running```
- Fix: Use ```/run modelName``` to load a model
  - Use ```/list``` to get available models

Error: ```registry.ollama.ai/library/modelName does not support tools```
- Fix: ```/config tools off```

Error: ```registry.ollama.ai/library/modelName does not support thinking```
- Fix: ```/config think off```

## Example chat

```html
% ./ollama-bash-toolshed.sh qwen3:8b

 ███████████                   ████          █████                   █████
░█░░░███░░░█                  ░░███         ░░███                   ░░███
░   ░███  ░   ██████   ██████  ░███   █████  ░███████    ██████   ███████
    ░███     ███░░███ ███░░███ ░███  ███░░   ░███░░███  ███░░███ ███░░███
    ░███    ░███ ░███░███ ░███ ░███ ░░█████  ░███ ░███ ░███████ ░███ ░███
    ░███    ░███ ░███░███ ░███ ░███  ░░░░███ ░███ ░███ ░███░░░  ░███ ░███
    █████   ░░██████ ░░██████  █████ ██████  ████ █████░░██████ ░░████████
   ░░░░░     ░░░░░░   ░░░░░░  ░░░░░ ░░░░░░  ░░░░ ░░░░░  ░░░░░░   ░░░░░░░░

ollama-bash-toolshed v0.36

/help for commands. /quit or Ctrl+C to exit.

ollama-bash-toolshed (qwen3:8b) (5 tools) [0 requests] [1 messages]
>>> /config think on

think: on

ollama-bash-toolshed (qwen3:8b) (5 tools) [0 requests] [1 messages]
>>> what tools do you have available?

🤔💭 Okay, the user is asking, "what tools do you have available?" Let me check the tools 
section again.

Looking at the provided tools, there's the calculator, datetime, man, ollama, and webpage 
functions. Each has specific descriptions and parameters. The user wants to know the 
available tools, so I should list them. But the exact answer depends on the /tools command.
Wait, the user might be asking for the list of tools, which is covered by the /tools command. 
But the assistant's tools are the functions listed in the <tools> section. So the answer 
should mention each tool's name and a brief description. Let me structure that. Also, the user 
might want to know what each tool does, so including the descriptions from the function 
definitions would be helpful. Let me make sure to list each tool with its purpose. For 
example, calculator for math, datetime for current time, man for command manuals, ollama for 
interacting with the Ollama app, and webpage for fetching web pages. That should cover it. I 
should present this in a clear, user-friendly way without using markdown. Alright, time to 
put that together. 💭🤔

Here are the tools I have available:

1. **calculator** - Perform math calculations (e.g., `calculator input="2+2"`).
2. **datetime** - Get the current date and time.
3. **man** - Read command manuals (e.g., `man command`).
4. **ollama** - Interact with the Ollama application (e.g., `ollama run model-name`).
5. **webpage** - Fetch web pages as text or raw HTML (e.g., `webpage url="https://example.com"`).

Let me know if you'd like details about a specific tool!

ollama-bash-toolshed (qwen3:8b) (5 tools) [1 requests] [3 messages]
>>> what time is it?

🤔💭 Okay, the user asked, "what time is it?" I need to figure out which tool to use here. 
Looking at the available tools, there's the 'datetime' tool that gets the current date and 
time. The parameters for that tool don't require anything, so I can call it without arguments. 
Let me check the function definition again to make sure. Yep, the 'datetime' function has 
no required parameters. So I should generate a tool call to 'datetime' with an empty arguments 
object. That should retrieve the current time and provide the answer to the user. 💭🤔

[TOOL] call: {"name":"datetime","arguments":{}}
[TOOL] result: 30 chars, 1 lines, first line: Fri Jun 27 20:01:14 CEST 2025

🤔💭 Okay, the user asked, "what time is it?" I need to provide the current time. Let me check 
the tools available. There's a 'datetime' tool that gets the current date and time. I'll call 
that tool. The response from the tool is "Fri Jun 27 20:01:14 CEST 2025". Wait, that seems 
like a future date. Maybe there's a typo? The year 2025 is in the future. But perhaps the 
tool's response is correct, or maybe it's a test scenario. Regardless, I should present the 
time as given. The user might be checking if the tool works correctly. I'll format the response 
to show the time in a friendly way, mentioning the date and time provided by the tool. Let me 
make sure to use the correct ANSI colors for the time display. Maybe use cyan for the time to 
make it stand out. Also, check if the user needs anything else after providing the time. 💭🤔

The current time is:
`Fri Jun 27 20:01:14 CEST 2025`

Let me know if you need anything else!

ollama-bash-toolshed (qwen3:8b) (5 tools) [3 requests] [7 messages]
>>> /messages
[
  {
    "role": "system",
    "content": "You are an AI assistant.\n- You are inside the Ollama Bash Toolshed.\n- You are running on the Ollama application.\n\nYou have access to these tools:\n\n'calculator' - Perform any standard math calculation (using bc input format)\n'datetime' - Get the current date and time\n'man' - Read command manuals\n'ollama' - Interact with the Ollama application (list, ps, run, show, stop, version)\n'webpage' - Get a web page, in format 'text' or 'raw' (defaults to 'text') ('raw' for HTML source)\n\nUse these tools to assist the user.\n- The tools can help you access information from the internet, solve complex math, get the current time,\n  understand commands and explore Ollama models.\n- Always tell the user the results of your tool calls.\n- Base your response on data you get from using the tools, and/or your own knowledge.\n\nYour response is rendered in a text terminal.\n- You may use ANSI escape codes to color your response.\n- COLOR    FOREGROUND      BACKGROUND\n  red      `\\033[31m`   `\\033[41m`\n  green    `\\033[32m`   `\\033[42m`\n  yellow   `\\033[33m`   `\\033[43m`\n  blue     `\\033[34m`   `\\033[44m`\n  magenta  `\\033[35m`   `\\033[45m`\n  cyan     `\\033[36m`   `\\033[46m`\n  black    `\\033[30m`   `\\033[40m`\n  white    `\\033[37m`   `\\033[47m`\n- To reset text to default colors: `\\033[0m`\n\nYou can assist with commands the user may use inside Ollama Bash Toolshed.\n- Only the user may use these commands.\n- Command list:\n\nModel Commands:\n  /list            - List models\n  /ps              - List running models\n  /pull modelName  - Pull new model\n  /run modelName   - Run a model\n  /show            - Current model info\n  /show modelName  - Model info\n  /stop modelName  - Stop a running model\n\nTool Commands:\n  /tools           - list tools available\n  /instructions    - list instructions for all tools\n  /tool toolName   - show tool definition\n  /exec toolName param1=\"value\" param2=\"value\" - run a tool, with optional parameters\n\nSystem Commands:\n  /multi             - enter multi-line prompt\n  /messages          - list of current messages\n  /system            - show system prompt\n  /clear             - clear the message and model cache\n  /config            - view all configs (tools, think, verbose)\n  /config name       - view a config\n  /config name value - set a config to new value\n  /quit or /bye      - end the chat\n  /help              - list of all commands"
  },
  {
    "role": "user",
    "content": "what tools do you have available?"
  },
  {
    "role": "assistant",
    "content": "Here are the tools I have available:\n\n1. **calculator** - Perform math calculations (e.g., `calculator input=\"2+2\"`).\n2. **datetime** - Get the current date and time.\n3. **man** - Read command manuals (e.g., `man command`).\n4. **ollama** - Interact with the Ollama application (e.g., `ollama run model-name`).\n5. **webpage** - Fetch web pages as text or raw HTML (e.g., `webpage url=\"https://example.com\"`).\n\nLet me know if you'd like details about a specific tool!"
  },
  {
    "role": "user",
    "content": "what time is it?"
  },
  {
    "role": "assistant",
    "tool_calls": [
      {
        "function": {
          "name": "datetime",
          "arguments": {}
        }
      }
    ]
  },
  {
    "role": "tool",
    "name": "datetime",
    "content": "Fri Jun 27 20:01:14 CEST 2025"
  },
  {
    "role": "assistant",
    "content": "The current time is:  \n`\\033[36mFri Jun 27 20:01:14 CEST 2025\\033[0m`  \n\nLet me know if you need anything else!"
  }
]
```

## Attogram Artificial Intelligence Projects

* [ollama-multirun](https://github.com/attogram/ollama-multirun) — A bash shell script to run a single prompt against any or all of your locally installed ollama models, saving the output and performance statistics as easily navigable web pages.
* [llm-council](https://github.com/attogram/llm-council) — A bash script to start a chat between 2 or more LLMs running on ollama
* [ollama-bash-toolshed](https://github.com/attogram/ollama-bash-toolshed) — Bash scripts to chat with tool using models. Add new tools to your shed with ease. Runs on Ollama.
* [small-models](https://github.com/attogram/small-models) — Comparison of small open source LLMs
* [AI Test Zone](https://github.com/attogram/ai_test_zone) — Demos hosted on https://attogram.github.io/ai_test_zone/
