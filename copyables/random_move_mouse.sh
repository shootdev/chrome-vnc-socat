#!/bin/bash

export DISPLAY=:1

DURATION=$1
START_TIME=$(date +%s)

while true; do
  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - START_TIME))

  if [ "$ELAPSED" -ge "$DURATION" ]; then
    exit 0
  fi

  SCREEN=$(xdotool getdisplaygeometry)
  SCREEN_W=$(echo "$SCREEN" | cut -d' ' -f1)
  SCREEN_H=$(echo "$SCREEN" | cut -d' ' -f2)

  RAND_X=$((RANDOM % SCREEN_W))
  RAND_Y=$((RANDOM % SCREEN_H))

  xdotool mousemove --sync "$RAND_X" "$RAND_Y"
  sleep 0.5
done
