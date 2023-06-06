#!/bin/bash
clear

function timestamp {
  local fname=${FUNCNAME[0]}
  local seconds=$1
  _timestamp_=""

  ((sec=seconds%60, seconds/=60, min=seconds%60, hrs=seconds/60))

  local plural="s"
  if ((sec == 1)); then
    plural=""
  fi

  if ((hrs == 0 && min == 0)); then
    printf -v _timestamp_ "%d second%s" $sec $plural
  elif (( hrs == 0 && min > 0)); then
    printf -v _timestamp_ "%d:%02d" $min $sec
  else
    printf -v _timestamp_ "%d:%02d:%02d" $hrs $min $sec
  fi
}

# Prints array elements in format "{index}\t{element}".
function printArray {
  local arr=("$@")
  for i in "${!arr[@]}"; do 
    printf "%s\t%s\n" "$i" "${arr[$i]}"
  done
}

function printStrOfChar {
  length=$1
  char=$2
  if ((length > 0)); then
    #printf '%*s' "$length" | tr ' ' "$char"
    printf "$char""%.0s" $(seq 1 $length) #support whitespace char
  fi
}
function printLineOfChar {
  printStrOfChar $1 $2
  printf "\n"
}
function printCenter {
  length=$1
  string=$2
  diff=$(($length-${#string}))
  count=$(($diff/2))
  end=$(($count+$diff%2))

  printStrOfChar $count ' '
  printf "$lineCommand"
  printLineOfChar $end ' '
}

start=$(date +%s)
started=$(date +%T)
command="nordvpn status"

while true
do
  today=$(date +%c)
  time=$(date +%T)
  now=$(date +%s)
  seconds=$(($now-$start))
  timestamp $seconds
 
  # Print out all lines for analysis
  lineCommand=$(echo $command | tr '[:lower:]' '[:upper:]')
  lineToday=$(echo "Today: $today")
  lineStarted=$(echo "Started: $started")
  lineRunning=$(echo "Running: $_timestamp_")
  lineTime=$(echo "Current time: $time")
  lines=("$lineCommand" "$lineToday" "$lineStarted" "$lineRunning" "$lineTime")
  #printArray "${lines[@]}"
  
  # Find the longest line
  declare -i maxLen=0
  for i in "${!lines[@]}"; do
    line=${lines[$i]}
    length=${#line}
    if ((maxLen < length)); then
      maxLen=$length
    fi
  done

  # Print to terminal window
  clear
  #sharp='#'
  printLineOfChar $((maxLen+2)) '#'
  if ((${#lineCommand} >= $maxLen)); then
    echo \# $lineCommand
  else
    printf "# "
    printCenter $maxLen "$lineCommand"
  fi
  printLineOfChar $((maxLen+2)) '#'
  echo \# $lineToday
  echo \# $lineStarted
  printf "#"; printLineOfChar $((maxLen+1)) '~'
  echo

  nordvpn status
  
  echo
  printf "#"; printLineOfChar $((maxLen+1)) '~'
  echo \# $lineRunning
  echo \# $lineTime
  echo \# Press [Ctrl+C] to stop...
  sleep 1
done
