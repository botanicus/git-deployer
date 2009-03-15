#!/bin/zsh

cd hooks
for hook in **/*(.) ; do
  echo "Running ... ln -sf $(pwd)/$hook /$hook"
  ln -sf "$(pwd)/$hook" "/$hook"
done
