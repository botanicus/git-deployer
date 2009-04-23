#!/bin/bash

# script for backuping server data

# === Cron configuration === #

# == Help == #
# crontab -e
# # 1. min | 2. hour | 3. day in month | 4. month | 5. day in week | 6. command
# # day in week: Sunday = 0, Saturday = 6

# == Example == #
# # each day in 4:00 backup /etc and uploads
# 0 4 * * * backup.sh /etc uploads
# # each day in 5:00 send backups to remote server
# 0 5 * * * backup.sh /etc uploads
# # each hour backup databases
# 0 * * * * backup.sh databases

# colors
red()   { echo -e "\e[1;31m$*\e[0m"; }
green() { echo -e "\e[1;32m$*\e[0m"; }
blue()  { echo -e "\e[1;34m$*\e[0m"; }

if [ "$1" = "--help" ] ; then
  blue "=== Usage ==="
  echo "backup.sh databases"
  echo "backup.sh uploads"
  echo "backup.sh /etc"
  echo "backup.sh databases /etc"
  echo
  blue "=== Options ==="
  echo "--follow-symlinks"
  echo
  blue "=== Environment ==="
  echo "DATADIR   points to dir with data [Example: /webs/data]"
  echo "BACKUPDIR points to dir with data [Example: /webs/backups]"
  exit 1
fi

# cron does not read this file
source /etc/profile
cd "$BACKUPDIR"

if [ "$DATADIR" = "" ] ; then
  echo "DATADIR environment variable must be set"
  exit 1
fi

if [ "$BACKUPDIR" = "" ] ; then
  echo "BACKUPDIR environment variable must be set"
  exit 1
fi

# tar note
# h means follow symlinks
# use absolute symlinks paths

# must be set just once, otherwise it can cause strange problems
now=$(date +%y-%m-%d-%H-%M)
exitvalue=0

backup() {
  if [ "$follow" = "true" ] ; then
    echo "Following symlinks in $1 ..."
    taropts=cjpfh
  else
    echo "Not following symlinks $1 ..."
    taropts=cjpf
  fi
  logdir="$BACKUPDIR/logs"
  mkdir -p "$(basename $1)" $logdir
  # log just when tar fails
  if tar $taropts "$(basename $1)/$now.tbz" "$1" 2> "$logdir/$now.log" ; then
    rm "$logdir/$now.log"
    rmdir $logdir 2> /dev/null
  else
    echo "Problems occured during archiving $1"
    exitvalue=1
  fi
}

for item in `echo $* | tac -rs '\s'`; do
  if [ `expr match $item ^--` != 0 ] ; then
    case $item in
      --follow-symlinks) follow=true;;
    esac
  else
    if [ -e "$DATADIR/$item" ] ; then
      if [ "$follow" != "true" ] ; then
        # TODO: this should work
        red "You need to follow symlinks. Use --follow-symlinks option"
        exit 1
      fi
      backup "$DATADIR/$item"
    # backup.sh /etc
    elif [ -e "$item" ] ; then
      backup "$item"
    # backup.sh uploads
    else
      echo "Directory '$item' does not exist (in / nor in '$DATADIR')"
      exit 1
    fi
  fi
done

exit $exitvalue
