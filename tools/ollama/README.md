# ollama

**ollama** - A tool for the [Ollama Bash Toolshed](../../).

# scripts
- ```list.sh```
- ```ps.sh```
- ```show.sh```

# Example running locally

```/exec ollama action=ollama_version```

```/exec ollama action=models_list```

```/exec ollama action=model_info model=qwen3:0.6b```

# Parameters

- ```action``` (required)
- ```model``` (required for action=model_info)

# Requirements

- ```ollama``` command
