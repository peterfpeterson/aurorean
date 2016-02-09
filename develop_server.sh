#!/usr/bin/env bash
BASEDIR=$(pwd)
OUTPUTDIR=$BASEDIR/site
PYTHON=$(command -v python)

###
# Don't change stuff below here unless you are sure
###

SRV_PID=$BASEDIR/srv.pid

function usage(){
  echo "usage: $0 (stop) (start) (restart) [port]"
  exit 3
}

function alive() {
  kill -0 $1 >/dev/null 2>&1
}

function shut_down(){
  PID=$(cat $SRV_PID)
  if [[ $? -eq 0 ]]; then
    if alive $PID; then
      echo "Stopping HTTP server (pid=$PID)"
      kill $PID
    else
      echo "Stale PID, deleting"
    fi
    rm $SRV_PID
  else
    echo "HTTP server PIDFile not found"
  fi
}

function start_up(){
  local port=$1
  echo "Starting up HTTP server"
  shift
  cd $OUTPUTDIR
  $PYTHON -m SimpleHTTPServer $port &
  srv_pid=$!
  echo $srv_pid > $SRV_PID
  cd $BASEDIR
  sleep 1
  if ! alive $srv_pid ; then
    echo "The HTTP server didn't start. Is there another service using port" $port "?"
    return 1
  fi
  echo 'HTTP server processes now running in background.'
  echo "navigate to http://localhost:$port"
}

###
#  MAIN
###
[[ ($# -eq 0) || ($# -gt 2) ]] && usage
port='8000'
[[ $# -eq 2 ]] && port=$2

if [[ $1 == "stop" ]]; then
  shut_down
elif [[ $1 == "restart" ]]; then
  shut_down
  start_up $port
elif [[ $1 == "start" ]]; then
  if ! start_up $port; then
    shut_down
  fi
else
  usage
fi
