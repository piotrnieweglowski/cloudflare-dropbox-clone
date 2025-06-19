#!/bin/bash
# scripts/list.sh

source "$(dirname "$0")/config.sh"

echo "Listing all files at $BASE_URL/files"
curl -s "$BASE_URL/files" | jq
