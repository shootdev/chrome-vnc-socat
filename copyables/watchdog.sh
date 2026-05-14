#!/bin/bash
set -e

LOG_FILE="/tmp/socat.log"
IDLE_MAX=1200
CHECK_INTERVAL=10
COOLDOWN=1200
LAST_KILL=0

echo "$(date): Socat log watchdog started. Watching $LOG_FILE"

while true; do
  sleep $CHECK_INTERVAL

  CHROME_PID=$(pgrep -f '/opt/google/chrome/chrome')

  if [ -z "$CHROME_PID" ]; then
    echo "$(date): Chrome is not running."
    continue
  else
    echo "$(date): Detected Chrome PID: $CHROME_PID"
  fi

  if [ ! -f "$LOG_FILE" ]; then
    echo "$(date): Socat log file not found: $LOG_FILE"
    echo "$(date): Killing chrome PID $CHROME_PID due to missing socat log file."
    kill -TERM $CHROME_PID || true
    LAST_KILL=$(date +%s)
    continue
  fi

  last_mod=$(stat -c %Y "$LOG_FILE")
  now=$(date +%s)
  idle=$((now - last_mod))

  echo "$(date): Socat log file last modified $idle seconds ago."
  echo "$(date): Last time kill at $LAST_KILL"

  if [ $idle -gt $IDLE_MAX ] && [ $((now - LAST_KILL)) -gt $COOLDOWN ]; then
    echo "$(date): No log update for $idle seconds. Killing Chrome PID $CHROME_PID"
    kill -TERM $CHROME_PID || true
    LAST_KILL=$(date +%s)
  fi
done
