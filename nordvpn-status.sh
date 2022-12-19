clear

function timestamp {
  local fname=${FUNCNAME[0]}
  local seconds=$1
  _timestamp_=""

  ((sec=seconds%60, seconds/=60, min=seconds%60, hrs=seconds/60))

  local plural="s"
  if ((sec == 1))
  then plural=""
  fi

  if ((hrs == 0 && min == 0)); then
    printf -v _timestamp_ "%d second%s" $sec $plural
  elif (( hrs == 0 && min > 0)); then
    printf -v _timestamp_ "%d:%02d" $min $sec
  else
    printf -v _timestamp_ "%d:%02d:%02d" $hrs $min $sec
  fi
}

#today=$(date +%c)
start=$(date +%s)
started=$(date +%T)

while true
do
  clear
  echo "#########################"
  echo "#     NORDVPN Status     "
  echo "#########################"
  echo "# Today:" $(date +%c)
  echo "# Started:" $started $'\n'

  nordvpn status
  
  now=$(date +%s)
  seconds=$(($now-$start))

  timestamp $seconds
  echo -e "\n# Running:" $_timestamp_
  
  t=$(date +%T)
  echo "# Current time:" $t

  echo "# Press [Ctrl+C] to stop..."
  sleep 1
done

