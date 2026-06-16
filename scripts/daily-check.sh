#!/bin/bash
set -e

# Fetch latest version from Node.js dist, use jq to extract it, and remove the 'v'
LATEST_NODE_VERSION=$(curl -s https://nodejs.org/dist/index.json | jq -r '.[0].version' | sed 's/^v//')
LATEST_PUBLISHED_VERSION=$(head -n 1 version.txt | sed 's/^v//' | tr -d '\r\n')

# Compare versions using sort -V (version sort)
HIGHEST=$(printf "%s\n%s" "$LATEST_NODE_VERSION" "$LATEST_PUBLISHED_VERSION" | sort -V | tail -n 1)

if [ "$HIGHEST" != "$LATEST_NODE_VERSION" ] || [ "$LATEST_NODE_VERSION" = "$LATEST_PUBLISHED_VERSION" ]; then
    echo "Nothing to do!"
    exit 0
fi

echo "NOTHING_TO_DO=false" >>"$GITHUB_ENV"
echo "TAG=v${LATEST_NODE_VERSION}" >>"$GITHUB_ENV"

echo "v${LATEST_NODE_VERSION}" >version.txt
