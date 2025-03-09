#!/bin/sh

killall -q polybar
killall -q .polybar-wrappe
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    echo $MONITOR
    MONITOR=$m polybar --reload top &
  done
else
  polybar --reload top &
fi
