#!/bin/zsh

cd hooks
for hook in **/*(.) ; do
  echo "ln -sf $(pwd)/$hook /$hook"
  #ln -sf "$(pwd)/$hook" "/$hook"
done
