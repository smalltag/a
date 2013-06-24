# get/set size of the terminal

usage ()
{
  echo usage: $0 ROWS COLUMNS
  set '3!d; s/....$/ 0x&/'
  set $(reg query 'hkcu\console' -v ScreenBufferSize | sed "$1")
  echo current buffer rows $(($3))
  echo current buffer columns $(($4))
  exit
}

warn ()
{
  printf '\e[36m%s\e[m\n' "$*"
}

log ()
{
  unset PS4
  qq=$((set -x; : "$@") 2>&1)
  warn "${qq:2}"
  eval "${qq:2}"
}

[ $1 ] || usage
# convert to hex
printf -v rows %04x $1
printf -v columns %04x $2
set -- -f -t reg_dword
log reg add 'hkcu\console' -v WindowSize -d 0x0019$columns "$@"
log reg add 'hkcu\console' -v ScreenBufferSize -d 0x$rows$columns "$@"
echo Restart console to see changes.
