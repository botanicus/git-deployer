#!/bin/bash

# script for sending backups to remote server

# === Cron configuration === #

# == Help == #
# 1. min | 2. hour | 3. day in month | 4. month | 5. day in week | 6. command
# day in week: Sunday = 0, Saturday = 6

# == Example == #
# # each day in 5:00 send backups to remote server
# 0 5 * * * sendremote.sh

# cron does not read this file
source /etc/profile

# colors
red()   { echo -e "\e[1;31m$*\e[0m"; }
green() { echo -e "\e[1;32m$*\e[0m"; }
blue()  { echo -e "\e[1;34m$*\e[0m"; }

if [ "$1" = "--help" ] ; then
  blue "=== Environment ==="
  echo "BACKUPDIR    points to dir with data [Example: /webs/backups]"
  echo "BACKUPSERVER points to remote server [Example: backup@remote.com:]"
  echo "BACKUPSERVERPATH points to path on remote server where are placed backups [Example: /backups]"
  exit 1
fi

if [ "$BACKUPDIR" = "" ] ; then
  red "BACKUPDIR environment variable must be set"
  exit 1
fi

if [ "$BACKUPSERVER" = "" ] ; then
  red "BACKUPSERVER environment variable must be set"
  exit 1
fi

today=$(date +%y-%m-%d)
for archive in "$BACKUPDIR/"*/$today* ; do
  basename=$(date +%H-%M).tbz
  path="$BACKUPSERVERPATH/$today/$(basename $(dirname $archive))"
  ssh $BACKUPSERVER mkdir -p "$path"
  scp "$archive" "$BACKUPSERVER:$path/$basename"
done
