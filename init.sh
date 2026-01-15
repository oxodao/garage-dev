#!/usr/bin/env bash
set -euo pipefail

: "${GARAGE_BUCKET:?GARAGE_BUCKET must be set}"

KEY_NAME="app"
ZONE="dc1"
CAPACITY="10T"

garage server > /dev/null &
PID="$!"

# Wait for garage to be ready
for i in {1..60}; do
  if garage status >/dev/null 2>&1; then break; fi
  sleep 1
done

# Get the node id
NODE_ID="$(garage status | grep '\[::\]:3901' | cut -d' ' -f1)"
echo "Node ID: " $NODE_ID
test -n "${NODE_ID}"

# Check if there is a layout assigned
STATUS="$(garage layout show 2>/dev/null || true)"
if grep -q 'No nodes currently have a role' <<< "$STATUS"; then
  if ! grep -q 'STAGED ROLE CHANGES' <<< "$STATUS"; then
    echo "No roles, assigning roles to node ${NODE_ID}"
    garage layout assign -z "${ZONE}" -c "${CAPACITY}" "${NODE_ID}"
  fi

  echo 'Applying new layout'
  garage layout apply --version 1
  echo "Layout assigned and applied."
else
  echo "Layout is OK"
fi

# Create the bucket if missing
BUCKET_LIST="$(garage bucket list)"
if ! awk '{print $3}' <<< "$BUCKET_LIST" | grep -q "^${GARAGE_BUCKET}$"; then
  echo 'Creating bucket: ' $GARAGE_BUCKET
  BUCKET_ID="$(garage bucket create $GARAGE_BUCKET | grep 'Bucket:' | awk '{print $2}')"
  echo 'Bucket created: ' $BUCKET_ID
else
  BUCKET_ID="$(grep " ${GARAGE_BUCKET} " <<< "$BUCKET_LIST" | awk '{print $1}')"
  echo 'Bucket already exists: ' $GARAGE_BUCKET ' / ' $BUCKET_ID
fi

# Create the key if missing
if ! garage key list | awk '{print $3}' | grep -qx "${KEY_NAME}"; then
  echo 'No key found, creating one'
  GARAGE_KEY="$(garage key create $KEY_NAME)"
else
  echo 'Key already exists, fetching info'
  GARAGE_KEY="$(garage key info $KEY_NAME --show-secret)"
fi

KEY_ID="$(grep 'Key ID:' <<< $GARAGE_KEY | cut -d':' -f2 | tr -d ' ')"
KEY_SECRET="$(grep 'Secret key:' <<< $GARAGE_KEY | cut -d':' -f2 | tr -d ' ')"

echo "Key infos: ID=${KEY_ID} SECRET=${KEY_SECRET}"

# Set the permissions
garage bucket allow --read --write --owner "${GARAGE_BUCKET}" --key "${KEY_NAME}" > /dev/null

echo "Writing credentials to /opt/garage/credentials.json"
echo "{\"bucket\": \"$GARAGE_BUCKET\", \"bucket_id\": \"${BUCKET_ID}\", \"key_id\": \"${KEY_ID}\", \"key_secret\": \"${KEY_SECRET}\"}" > /opt/garage/credentials.json

touch /opt/garage_up

wait "$PID"