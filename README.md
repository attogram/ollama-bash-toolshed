# Ollama Bash Toolshed

![Logo](docs/logo/logo.500x250.jpg)

Bash scripts to chat with tool using models. Add new tools to your shed with ease. Runs on Ollama.

## Usage

* Run the toolshed:
    ```
    ./ollama-bash-toolshed.sh
    ```
  * This will start the toolshed with no model loaded
  * use ```/list``` to get list of available models
  * use ```/load modelName``` to load a model

* Run the toolshed with a specific model:
  ```
  ./ollama-bash-toolshed.sh "modelname"
  ```

* You MUST use a model with tools capabilities.
  * See the [ollama.com Tools models](https://ollama.com/search?c=tools) list.
  * See the [small models for tool usage](https://github.com/attogram/small-models/tree/main#tool-usage) list.
 
## User commands

Ollama Bash Toolshed User Commands:

* ```/help``` - list of commands
* ```/list``` - view models installed
* ```/load <modelName>``` - load the model
* ```/show <modelName>``` - view info about model
* ```/tools``` - list tools available
* ```/run <toolName> parameterName=parameterValue``` - run a tool
* ```/messages``` - list of current messages
* ```/clear``` - clear the message cache
* ```/quit``` or ```/bye``` - end the chat

### Examples of running tools locally

* ```/run calculator input="1 + 2"```
* ```/run man command=wc```
* ```/run webpage url="https://ollama.com/search?c=tools"```

## Tools in the shed

* [calculator](tools/calculator) — Do math calculations
* [datetime](tools/datetime) — Get the current date and time
* [man](tools/man) - Get manual page for a command
* [webpage](tools/webpage) — Get a web page (text-version, or raw source)
* [ollama](tools/ollama) — Get model list, model info, ollama version

## Add a new tool

Read about the [tools setup](tools/README.md).

To add a new tool:

- Give your tool a name.  Example: ```getWeather```
- create a subdirectory in ```tools/``` directory. Example: ```tools/getWeather/```
- create a JSON tool definition file. Example: ```tools/getWeather/definition.json```
- create a bash script to run the tool. Example: ```tools/getWeather/run.sh```
- chmod your bash script. Example: ```chmod +x tools/getWeather/run.sh```
- your tool subdirectory and file names MUST be your tool name
- run ```./ollama-bash-toolshed.sh "modelname"``` to chat using your new tool

## Example chat

```html
% ./ollama-bash-toolshed.sh qwen3:8b

ollama-bash-toolshed v0.1

Model: qwen3:8b
Available Tools: getBashVersion getDateTime getOllamaVersion getWebPage
Press Ctrl+C to exit

Prompt: what time is it?

[TOOL] getDateTime {}

<think>
Okay, the user asked, "what time is it?" I called the getDateTime function, which returned "Fri Jun 20 21:44:58 CEST 2025". Now I need to present this information clearly. Let me check the format. The date and time are in a standard format, so I can just relay that. The user might want to know the current time, so maybe I should mention it's the current date and time. Let me make sure there's no time zone confusion. The CEST indicates Central European Summer Time, which is UTC+2. If the user is in a different time zone, they might need to adjust, but since they didn't specify, I'll just provide the time as is. Alright, the response should be straightforward.
</think>

The current date and time is **Fri Jun 20 21:44:58 CEST 2025**. Let me know if you need further assistance!

Prompt: what version of bash and ollama are installed?

[TOOL] getBashVersion {}

[TOOL] getOllamaVersion {}

<think>
Okay, let's see. The user asked for the versions of Bash and Ollama installed.

First, I called the getBashVersion tool. The response came back as "3.2.57(1)-release". That's the Bash version. Then, I called getOllamaVersion, which returned "ollama version is 0.9.2".

So, I need to present both versions clearly. Let me check if the responses are correctly formatted. The Bash version seems standard, and the Ollama version is straightforward.

I should mention both versions in a friendly manner. Maybe start with Bash first since that's what the user might expect. Make sure to format the Ollama version correctly, perhaps using bold or a code block if needed.

Wait, the user might be checking for specific versions for compatibility or troubleshooting. Including both versions in a clear statement should address their query. Let me structure the response to be concise and informative.
</think>

The installed software versions are:
- **Bash**: `3.2.57(1)-release`
- **Ollama**: `0.9.2`

Let me know if you need further details!

Prompt: what projects are listed on https://attogram.github.io/ ?

[TOOL] getWebPage {
  "url": "https://attogram.github.io/"
}

<think>
Okay, let me see. The user asked what projects are listed on https://attogram.github.io/. I called the getWebPage function with that URL, and the response is the HTML content of the page.

Now I need to parse the HTML to extract the project names. Looking at the HTML, there are several <div class="project"> sections. Each project has a <div class="name"> which contains the project's name as a link.

I'll loop through each project div, find the name, and collect them. The names are linked, so I should extract the text inside the <a> tag. For example, the first project is "Just Refs" and so on.

I need to make sure I get all the project names correctly. Let me count how many there are. The HTML has multiple project entries, each with their own name. I'll list them all, ensuring no duplicates and correct spelling.

Once I have the list, I'll present it to the user in a clear, numbered format. Also, note that some projects have a demo or home link, but the user only asked for the project names, so I'll focus on that.

Double-checking the HTML to ensure I didn't miss any projects. The last project is "Attogram on Github" which is also included. That's 12 projects in total.

Alright, compiling the list now.
</think>

The website https://attogram.github.io/ lists the following projects:

1. **Just Refs** - Extracts reference links from Wikipedia pages
2. **Eight Queens** - Web game based on the classic chess puzzle
3. **Games Website Builder** - Tool to create customizable game websites
4. **Currency Exchange Rates** - Currency data aggregator with financial APIs
5. **Body Mass Info Table** - BMI calculator with health metrics
6. **Shared Media Tagger** - Crowdsourced media rating system
7. **Shared Media API** - MediaWiki API wrapper for Wikimedia Commons
8. **Attogram Router** - PHP 7 routing framework
9. **Clean Repo: Games** - Open-source game repository cleaner
10. **Open Translation Engine (OTE)** - Collaborative translation dictionary
11. **Randomosity Tester** - Tests randomness functions in PHP/SQLite
12. **Attogram on Github** - Repository management service

Let me know if you'd like details about any specific project!

Prompt:
```

## Attogram Artificial Intelligence Projects

* [ollama-multirun](https://github.com/attogram/ollama-multirun) — A bash shell script to run a single prompt against any or all of your locally installed ollama models, saving the output and performance statistics as easily navigable web pages.
* [llm-council](https://github.com/attogram/llm-council) — A bash script to start a chat between 2 or more LLMs running on ollama
* [ollama-bash-toolshed](https://github.com/attogram/ollama-bash-toolshed) — Bash scripts to chat with tool using models. Add new tools to your shed with ease. Runs on Ollama.
* [small-models](https://github.com/attogram/small-models) — Comparison of small open source LLMs
* [AI Test Zone](https://github.com/attogram/ai_test_zone) — Demos hosted on https://attogram.github.io/ai_test_zone/
