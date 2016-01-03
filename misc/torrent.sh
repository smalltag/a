#!/bin/sh
mirror=https://thepiratebay.vg
al="\
NAME
  torrent.sh

SYNOPSIS
  torrent.sh <search> <sort> <category>

SORT
  3  date ↓
  6  size ↑
  7  seeders ↓

CATEGORY
  100  Audio
  104  Audio FLAC
  201  Video Movies
  205  Video TV shows
  207  Video HD Movies
  208  Video HD TV shows
  301  Applications Windows
"

function browse {
  case $OSTYPE in
  linux-gnu) xdg-open "$1" ;;
  cygwin)    cygstart "$1" ;;
  esac
}

function warn {
  printf '\e[36m%s\e[m\n' "$*"
}

function log {
  sx=$(sh -xc ': "$@"' . "$@" 2>&1)
  warn "${sx:4}"
  "$@"
}

function exp {
  printf 'BEGIN {print %s}' "$1" | awk -f-
}

if [ $# != 3 ]
then
  printf "$al"
  exit
fi

sc=$1
sr=$2
cg=$3

if [ "$cg" != 207 ]
then
  browse "$mirror/search/$sc/0/$sr/$cg"
  exit
fi

cd /tmp
rm -f *.htm
upper=$(exp '3 * 1024 ^ 3')
log curl --com -so search.htm "$mirror/search/$sc/0/$sr/$cg"

awk '$2 == "torrent" {print $3}' FS=/ search.htm |
while read each
do
  printf '%8d\t' $each
  curl --com -so $each.htm $mirror/torrent/$each
  # check size
  sz=$(awk '/Bytes/ {print $NF}' FPAT=[[:digit:]]+ $each.htm)
  if (( sz > upper ))
  then
    echo too large
    continue
  fi
  # check bitrate
  br=$(awk '
  /[kK][bB][pP/][sS]/ {
    $0 = $(NF-1)
    sub(" ", "")
    print
  }
  ' FS='[^[:digit:]]{2,}' $each.htm | sort -nr | head -1)
  if [[ ! $br ]]
  then
    echo no bitrate
    continue
  fi
  if exp "$br < 2080" | grep -q 1
  then
    echo low bitrate
    continue
  fi
  # check size / bitrate
  if exp "$sz / $br < 500000" | grep -q 1
  then
    echo bad size / bitrate ratio
    continue
  fi
  # check seeders
  sd=$(awk '/Seeders/ {print RT}' RS=[[:digit:]]+ $each.htm)
  # $mirror/torrent/9941270
  if (( sd < 1 ))
  then
    echo low seeders
    continue
  fi
  echo good
  browse $mirror/torrent/$each
done
