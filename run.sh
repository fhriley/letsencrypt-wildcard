#!/usr/bin/env bash

interrupt() {
  echo
  echo "Caught ^C, exiting."
  exit 1
}

trap interrupt SIGINT

if [ -n "${ACCEPT_CA_TERMS:-}" ]; then
  DEHYDRATED_CMD="/dehydrated --accept-terms"
else
  DEHYDRATED_CMD="/dehydrated"
fi

while true; do
  $DEHYDRATED_CMD --cron --keep-going
  $DEHYDRATED_CMD --cleanup
  inotifywait --timeout 86400 /letsencrypt/domains.txt
  sleep 60
done
