set -euo pipefail

source ./config_files/shell_vars
source ./config_files/nodeinfo

is-running() {
  if [ $1 == prometheus ]
  then sudo systemctl is-active prometheus >/dev/null
  else pgrep -x $1 >/dev/null
  fi
}

before-start() {
  if is-running "$1"; then
    echo "Cannot start $1 because it's already running"
    exit 1
  fi
}

after-start() {
  sleep 2
  if ! is-running "$1"; then
    echo "Failed to start $1"
    exit 1
  fi
}

stop() {
  if ! is-running $1; then return 0; fi
  if [ $1 == prometheus ]
  then sudo systemctl stop prometheus >/dev/null
  else pkill $1
  fi
  sleep .5
  WAITCOUNT=0
  while is-running $1; do
    if [ $WAITCOUNT == 12 ]; then
      echo "$1 is still running 60 seconds after asked to stop. Sending SIGKILL."
      if pkill -9 $1; then
        # At least one process was sent a signal, as expected
        :
      else
        ec="$?"
        if is-running $1 || [ "$ec" -ne 1 ]; then
          echo "pkill -9 $1 failed with code $ec"
          exit "$ec"
        else
          # pkill failed with code 1 due to no process found, that's ok
          :
        fi
      fi
    fi
    echo "Waiting for $1 to stop..."
    sleep 5
    WAITCOUNT=$((WAITCOUNT + 1))
  done
}

need_rondb() {
  case $NODEINFO_ROLE in
  ndb_mgmd|ndbmtd|mysqld|rdrs|bench) return 0 ;;
  *) return 1 ;;
  esac
}
