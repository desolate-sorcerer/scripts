#!/bin/sh
clear

HOST=$(uname -n)
CPU=$(grep -m1 "model name" /proc/cpuinfo | cut -d ':' -f 2 | sed 's/^ //')
IP=$(ip a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | head -1)
MEM=$(free -m | awk 'NR==2{printf "Used: %sMB / Total: %sMB", $3, $2}')
GPU=$(lspci -v -s $(lspci | grep ' VGA ' | cut -d" " -f 1) | head -1 | cut -d '[' -f 2 | cut -d ']' -f 1)

ESC=$(printf '\033')
COLOR="${ESC}[32m"
NORMAL="${ESC}[0m"

SPACE="-------------------------------"

INFO=$(mktemp)
{
  printf '%s\n' "System Info"
  printf '%s\n' "$SPACE"
  printf '%sHOST:%s %s\n\n' "$COLOR" "$NORMAL" "$HOST"
  printf '%sCPU:%s %s\n\n' "$COLOR" "$NORMAL" "$CPU"
  printf '%sGPU:%s %s\n\n' "$COLOR" "$NORMAL" "$GPU"
  printf '%sMEM:%s %s\n\n' "$COLOR" "$NORMAL" "$MEM"
  printf '%sIP:%s %s\n' "$COLOR" "$NORMAL" "$IP"
  printf '%s\n' "$SPACE"
} >"$INFO"

WIDTH=$(awk '{ if (length($0) > m) m = length($0) } END { print m }' art)

awk -v w="$WIDTH" '
  NR==FNR { info[FNR + 1] = $0; n = FNR; next }
  { printf "%-" w "s   %s\n", $0, info[FNR] }
  END { for (i = FNR + 1; i <= n; i++) printf "%-" w "s   %s\n", "", info[i] }
' "$INFO" art

rm -f "$INFO"
