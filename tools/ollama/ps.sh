# https://github.com/ollama/ollama/blob/main/docs/api.md#list-running-models

curl -s -X GET "http://localhost:11434/api/ps" -H 'Content-Type: application/json' -d '' | jq
