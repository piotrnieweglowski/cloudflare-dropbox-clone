#!/bin/bash
# scripts/upload.sh

source "$(dirname "$0")/config.sh"

# Create unique file to upload
FILENAME="test-$(date +%s).txt"
echo "Test $(date)" > "$FILENAME"

# Upload and capture full response
echo "Uploading $FILENAME to $BASE_URL/files"
RESPONSE=$(curl -s -X POST "$BASE_URL/files" \
  -F "file=@$FILENAME" \
  -H "Accept: application/json")

# Save to individual file
RESPONSE_FILE="upload-response-$(date +%s).json"
echo "$RESPONSE" > "$RESPONSE_FILE"

# Extract useful info and append to uploads.log
ID=$(echo "$RESPONSE" | jq -r '.id')
UPLOADED_AT=$(echo "$RESPONSE" | jq -r '.uploaded_at')

echo "$ID  $FILENAME  $UPLOADED_AT" >> uploads.log

echo "✅ Upload complete:"
echo "  ↳ ID: $ID"
echo "  ↳ Metadata saved to: $RESPONSE_FILE"
echo "  ↳ Summary appended to: uploads.log"
