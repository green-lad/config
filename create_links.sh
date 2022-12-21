#!/bin/sh


SCRIPTPATH=$(dirname "$0")

while IFS="," read -r target name remaining_columns
do
  eval target="$target"
  eval name="$name"
  ln -sf $target $name
done < <(tail -n +2 "$SCRIPTPATH/links.csv")
