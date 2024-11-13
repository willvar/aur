#!/bin/bash

for dir in */; do
  if [ -d "$dir" ]; then
    (cd "$dir" && makepkg --printsrcinfo > .SRCINFO)
    echo "Generated .SRCINFO in $dir"
  fi
done