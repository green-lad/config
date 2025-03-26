#!/bin/sh

killall -q polybar
killall -q .polybar-wrappe
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
  # for m in $(xrandr --query | grep " connected" | grep -o -E "^[^ ]*"; do
    echo $MONITOR
    MONITOR=$m polybar top &
  done
else
  polybar top &
fi
