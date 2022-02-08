#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# take input for variable file
VARFILE="$1"
if ! [[ -e "$VARFILE" ]]; then
  echo "variable file $VARFILE not found"
  exit 1
fi

# change to project root dir
realpath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

SCRIPT_PATH=$(realpath "$0")
SCRIPT_PATH="${SCRIPT_PATH/buildworld.sh/}"
cd "$SCRIPT_PATH"

# kill all child proceses
kill_spawn() {
  for SPAWN in $(pgrep -g $$); do
    kill -2 "$SPAWN"
  done
}

# kill_spawn on exit and ctrl-c
trap kill_spawn EXIT SIGINT

# start full build
(
  packer build -force -only base.virtualbox-iso.macOS -var-file "$VARFILE" macOS.pkr.hcl &&
    packer build -force -only=customize.virtualbox-vm.macOS -var-file "$VARFILE" macOS.pkr.hcl
) &

# Wait for all builds to finish
wait

# end
echo "End of Line"
exit 0
