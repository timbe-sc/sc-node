#!/bin/bash

URL="https://nae-env.solvecare.net/sit-platform-can/nom/v2/nodes/self-hosted/$1"
AUTH_HEADER="Authorization: Basic c29sdmVjYXJlOnNlY3JldA=="
CONTENT_TYPE="Content-Type: application/json"

TUUMIO_DIR="$HOME/.tuumio"
REMOTE_REPO_URL="https://github.com/timbe-sc/sc-node.git"
REMOTE_BRANCH="main"

mkdir -p $TUUMIO_DIR

cd "$TUUMIO_DIR"
rm -rf .git
git clone -b "$REMOTE_BRANCH" "$REMOTE_REPO_URL" .

mkdir -p $TUUMIO_DIR/volume/storj/db

(crontab -l | grep '.tuumio') || crontab -l | { cat; echo "*/1 * * * * sh $TUUMIO_DIR/manage.sh >> $TUUMIO_DIR/manager.log"; } | crontab -

response=$(curl -s -X POST "$URL" \
  -H "$AUTH_HEADER" \
  -H "$CONTENT_TYPE")

node_address=$(echo "$response" | jq -r '.nodeAddress')
node_id=$(echo "$response" | jq -r '.nodeId')
tunnel_token=$(echo "$response" | jq -r '.tunnelToken')

echo "NODE_SC_ADDRESS=$node_address" > "$TUUMIO_DIR/.env"
echo "NODE_ID=$node_id" >> "$TUUMIO_DIR/.env"

cloudflared service uninstall $tunnel_token
cloudflared service install $tunnel_token