#!/bin/sh

marker_file="/tmp/dpms"

test_state() {
  (xset q | grep "DPMS is Disabled" -q)
}

print_state() {
  test_state
  if [ $? -eq 0 ]; then
    echo " 󱎴 "
  else
    echo " 󰍹 "
  fi
}

case "$1" in
  --toggle)
    test_state
    if [ $? -eq 0 ]; then
      echo 1 > "$marker_file"
      xset s on +dpms
    else
      echo 0 > "$marker_file"
      xset s off -dpms
    fi
    ;;
  *)
    # touch "$marker_file"
    print_state
    inotifywait -q -m -e modify "$marker_file" | while read -r "event" ; do
      print_state
    done
    ;;
esac
