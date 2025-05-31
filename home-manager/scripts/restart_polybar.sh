#!/bin/sh

killall -q polybar
killall -q .polybar-wrappe
mbsync -a
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    echo $MONITOR
    MONITOR=$m polybar top &
  done
else
  polybar top &
fi
