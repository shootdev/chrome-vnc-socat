#!/bin/bash

if command -v xdotool >/dev/null 2>&1; then
    echo "xdotool 存在"
else
  sudo sed -i 's#http://.*ubuntu.com#http://mirrors.aliyun.com#g' /etc/apt/sources.list && sudo apt-get update
  sudo apt-get install xdotool -y
fi

if [ "$(whoami)" = "seluser" ]; then
  export DISPLAY=:99
else
  export DISPLAY=:1
fi

START_X=$1
START_Y=$2
MOVE_LENGTH=$3
X_OFFSET=${4:-0}
Y_OFFSET=${5:-0}

END_X=$(( START_X + MOVE_LENGTH + X_OFFSET ))
END_Y=$(( START_Y + Y_OFFSET ))

echo "END_X=$END_X"
echo "END_Y=$END_Y"

random_range() {
    local min=$1
    local max=$2
    echo $(( min + RANDOM % (max - min + 1) ))
}

random_float() {
    local min=$1
    local max=$2
    awk -v min="$min" -v max="$max" -v seed="$RANDOM" \
        'BEGIN{srand(seed); printf "%.6f", min + rand()*(max-min)}'
}

STEPS=$(random_range 52 84)
MIN_DELAY=$(random_float 0.0005 0.0012)
MAX_DELAY=$(random_float 0.0018 0.0038)
START_TS=$(date +%s%N)

xdotool mousemove "$START_X" "$START_Y"
xdotool mousedown 1

DX=$(( END_X - START_X ))
DY=$(( END_Y - START_Y ))

for ((i=1; i<=STEPS; i++)); do
    JITTER_X=$(( RANDOM % 5 - 2 ))
    JITTER_Y=$(( RANDOM % 5 - 2 ))
    if [ "$i" -eq "$STEPS" ]; then
        JITTER_X=0
        JITTER_Y=0
    fi

    CX=$(awk -v sx="$START_X" -v dx="$DX" -v i="$i" -v s="$STEPS" -v jitter="$JITTER_X" \
        'BEGIN{printf "%.0f", sx + dx*(i/s) + jitter}')
    CY=$(awk -v sy="$START_Y" -v dy="$DY" -v i="$i" -v s="$STEPS" -v jitter="$JITTER_Y" \
        'BEGIN{printf "%.0f", sy + dy*(i/s) + jitter}')

    xdotool mousemove "$CX" "$CY"
    sleep "$(random_float "$MIN_DELAY" "$MAX_DELAY")"
done

xdotool mouseup 1
echo "DRAG_END"
END_TS=$(date +%s%N)
TOTAL_NS=$(( END_TS - START_TS ))
TOTAL_DURATION=$(awk -v ns="$TOTAL_NS" 'BEGIN{printf "%.4f", ns / 1000000000}')

POS=$(xdotool getmouselocation)
CUR_X=$(echo "$POS" | sed -n 's/.*x:\([0-9]*\).*/\1/p')
CUR_Y=$(echo "$POS" | sed -n 's/.*y:\([0-9]*\).*/\1/p')

echo "REAL_X=$CUR_X"
echo "REAL_Y=$CUR_Y"
echo "STEPS=$STEPS"
echo "TOTAL_DURATION=$TOTAL_DURATION"

TH=10

DX_ERR=$(( CUR_X - END_X ))
DY_ERR=$(( CUR_Y - END_Y ))
DX_ERR=${DX_ERR#-}
DY_ERR=${DY_ERR#-}

echo "DX_ERR=$DX_ERR"
echo "DY_ERR=$DY_ERR"

if [ "$DX_ERR" -le "$TH" ] && [ "$DY_ERR" -le "$TH" ]; then
    echo "DRAG_STATUS=SUCCESS"
    exit 0
else
    echo "DRAG_STATUS=FAILED"
    exit 2
fi
