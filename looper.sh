#!/bin/bash
clear

function timestamp {
  #echo Calling ${FUNCNAME[0]}...
  local __result__=$1
  local seconds=$2

  local -i sec min hrs
  ((sec=seconds%60, seconds/=60, min=seconds%60, hrs=seconds/60))

  local plural="s"
  if ((sec == 1)); then
    plural=""
  fi

  local result=""
  if ((hrs == 0 && min == 0)); then
    printf -v result "%d second%s" $sec $plural
  elif (( hrs == 0 && min > 0)); then
    printf -v result "%d:%02d" $min $sec
  else
    printf -v result "%d:%02d:%02d" $hrs $min $sec
  fi
  # return $result
  if [[ "$__result__" ]]; then
    eval $__result__="'$result'"
  else
    echo "$result"
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

function trimSpecialChars {
  #echo Calling ${FUNCNAME[0]}...
  local __result__=$1
  local str=$2

  # Remove UTF-8 BOM bytes
  str=$(iconv --from-code=UTF-8 -c <<< $str)

  # Escape new lines...
  str="${str//$'\n'/\{nl\}}"

  # Remove control chars...
  str=$(tr -d [:cntrl:] <<< "$str")

  # Index of alnum-substring
  local s="${str%%[[:alnum:]]*}"
  local index=${#s}
  str=${str:index} # make substring starting from first alnum-char

  # Last index of alnum-substring
  s="${str##*[[:alnum:]]}" # after last index
  index=$((${#str} - ${#s}))
  str=${str:0:index} # remove suffix with non-alnum chars

  # Recover new lines...
  str="${str//\{nl\}/$'\n'}"

  # return $str
  if [[ "$__result__" ]]; then
    eval $__result__="'$str'"
  else
    echo "$str"
  fi
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
  timestamp _timestamp_ $seconds
 
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
    #echo $i : $length : $line
  done

  # Header rendering
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
  # End of Header rendering

  #nordvpn status
  #eval "$command"
  output=$(eval "$command")
  # echo "$output"
  # echo

  trimSpecialChars content "$output"

  # echo Encode whitespaces...
  # content="${content// /\{whitespace\}}"
  # echo $content

  readarray -t lines <<< "$content"

  for i in "${!lines[@]}"; do
    line=${lines[$i]}
    length=${#line}
    # if ((maxLen < length)); then
    #   maxLen=$length
    # fi
    echo $i : $length : $line
  done

  # Footer rendering
  echo
  printf "#"; printLineOfChar $((maxLen+1)) '~'
  echo \# $lineRunning
  echo \# $lineTime
  echo \# Press [Ctrl+C] to stop...
  sleep 1
done
