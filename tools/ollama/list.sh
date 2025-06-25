#!/usr/bin/env bash
#
# ollama list
#
# A tool for the Ollama Bash Toolshed
#
# https://github.com/ollama/ollama/blob/main/docs/api.md#list-local-models

curl -s -X GET "http://localhost:11434/api/tags" -H 'Content-Type: application/json' -d ''
