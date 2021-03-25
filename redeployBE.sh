#!/usr/bin/env bash

set -o errexit
set -o nounset

readonly SSH_STRING=root@d2g.christopher.sg

ssh $SSH_STRING "
  tmux respawn-window -k -t backend
  tmux send-keys -t backend './server_redeployBE.sh' Enter
  tmux select-window -t backend
"

ssh -t $SSH_STRING "tmux a"
