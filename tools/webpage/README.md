# webpage

**webpage** - A tool for the [Ollama Bash Toolshed](../..).

Get a web page from the internet.

Defaults to getting the text-only version.  Getting raw source is also possible.

# Examples running locally
```/exec webpage url="https://ollama.com/search?c=thinking"```
```/exec webpage url="https://example.com/" format=raw```

# Parameters

- ```url``` (required)
- ```format``` ("text" or "raw") (optional) (default to "text")

# Requirements

- ```curl``` command
- ```lynx``` command
