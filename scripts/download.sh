#!/bin/bash
# scripts/download.sh

source "$(dirname "$0")/config.sh"

if [ -z "$1" ]; then
  echo "❌ Please provide a file ID to download"
  echo "Usage: ./download.sh <id>"
  exit 1
fi

FILE_ID=$1

echo "Downloading file $FILE_ID from $BASE_URL/files/$FILE_ID"
curl -L "$BASE_URL/files/$FILE_ID" -o "downloads/$FILE_ID"

echo "✅ Downloaded to downloads/$FILE_ID"
