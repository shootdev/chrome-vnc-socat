export DISPLAY=:1
sleep 1
xdotool key Ctrl+l
sleep 1
xdotool type "$1"
sleep 1
xdotool key Return
