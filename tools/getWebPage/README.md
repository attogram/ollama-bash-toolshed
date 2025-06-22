# Get Web Page

**getWebPage** - A tool for the [Ollama Bash Toolshed](../../).

Get a web page from the internet.

Default to getting text-only version.  Getting raw source is also possible.

# Local Usage example

```/run getWebPage url="https://ollama.com/search?c=thinking"```

```/run getWebPage url="https://example.com/" format=raw```

# Parameters

- ```url``` (required)
- ```format``` ("text" or "raw") (optional) (default to "text")

# Requirements

- ```curl``` command
- ```lynx``` command
