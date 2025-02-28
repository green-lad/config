#!/bin/sh

export XDG_CONFIG_HOME="$HOME/.config"

# "$XDG_CONFIG_HOME/miniflux/miniflux.conf,/etc/miniflux.conf" \

set \
  "$XDG_CONFIG_HOME/zsh/zshrc,~/.zshrc" \
  "$XDG_CONFIG_HOME/taskwarrior/taskrc,~/.taskrc" \
  "$XDG_CONFIG_HOME/gnupg/gpg-agent.conf,~/.gnupg/gpg-agent.conf" \
  "$XDG_CONFIG_HOME/xorg/xinitrc,~/.xinitrc" \
  "$XDG_CONFIG_HOME/xorg/fehbg,~/.fehbg" \
  "$XDG_CONFIG_HOME/xorg/xbindkeysrc,~/.xbindkeysrc" \
  "$XDG_CONFIG_HOME/firefox,~/.mozilla/firefox" \
  "$XDG_CONFIG_HOME/moc,~/.moc" \
  "$XDG_CONFIG_HOME/gtk-3.0/themes,~/.themes" \
  "$XDG_CONFIG_HOME/applications/neomutt.desktop,~/.local/share/applications/neomutt.desktop"

IFS=$','
for i
do
  set -- $i # Convert "tuple" into the param args $1 $2...
  eval target="$1"
  eval path="$2"
  dir=${path%/*}
  (test -d "$dir" || mkdir "$dir") && ln -sf "$target" "$path"
done

