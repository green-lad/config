#!/usr/bin/env -S nu

def main [percent: int] {
  let fb = "/sys/class/backlight/intel_backlight/brightness"
  let fm = "/sys/class/backlight/intel_backlight/max_brightness"
  let c = cat $fb | into int
  let m = cat $fm | into int
  let r = $c + $m / 100 * $percent | math round
  [0 $r $m] | math median | save -f $fb
}
