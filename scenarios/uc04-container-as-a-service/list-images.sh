#!/bin/bash

NAMESPACE=demo

echo -e "IMAGESTREAM:TAG\tSIZE (MB)"

# Get all ImageStreamTags in the namespace
for istag in $(oc get istag -n "$NAMESPACE" --no-headers | awk '{print $1}'); do
  # Extract image stream and tag name
  ISTREAM=$(echo "$istag" | cut -d':' -f1)
  TAG=$(echo "$istag" | cut -d':' -f2)

  # Get size in bytes
  SIZE_BYTES=$(oc get istag "$istag" -n "$NAMESPACE" -o jsonpath="{.image.dockerImageMetadata.Size}" 2>/dev/null)

  # If size is empty (e.g. image doesn't exist), skip
  if [[ -z "$SIZE_BYTES" ]]; then
    continue
  fi

  # Convert to MB
  SIZE_MB=$(( SIZE_BYTES / 1024 / 1024 ))
  #SIZE_MB=$(echo "$SIZE_BYTES / 1024 / 1024")

  # Output
  echo -e "${ISTREAM}:${TAG}\t${SIZE_MB}"
done
