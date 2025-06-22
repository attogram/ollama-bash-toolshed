# Tools Directory

This is the tools directory for the [Ollama Bash Toolshed](../).

Each subdirectory is a tool.

The name of the subdirectory is the name of the tool.


## Tool Definition

Tools are defined with the ```./tools/toolName/definition.json``` file.

Example definition, a tool with no parameters:
```json
{
  "type": "function",
  "function": {
    "name": "toolName",
    "description": "Description of the tool",
    "parameters": {
      "type": "object",
      "properties": {},
      "required": []
    }
  }
}
```

Example definition, a tool with a parameter:
```json
{
  "type": "function",
  "function": {
    "name": "toolName",
    "description": "Description of the tool",
    "parameters": {
      "type": "object",
      "properties": {
        "input": {
          "type": "string",
          "description": "Description of the 'input' property"
        }
      },
      "required": ["input"]
    }
  }
}

```

## Tool Runner

Tools are run via the ```./tools/toolName/run.sh``` file.

All ```run.sh``` files must be executable.
- ```chmod +x run.sh```

Tools receive parameters via a json block passed as the first argument:
```
{
  "input": "The value of the 'input' parameter"
}
```

In bash, to parse the parameters in the json block:
```bash
# get the command line arguments
arguments="$@" 

# get the 'input' value
input=$(echo "$arguments" | jq -r '.input') 
```
