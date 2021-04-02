#!/usr/bin/env bash

set -o errexit
set -o nounset

readonly SSH_STRING=root@d2g.christopher.sg
readonly GIT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)

ssh $SSH_STRING "
  tmux respawn-window -k -t backend
  tmux send-keys -t backend './server_redeployBE.sh $GIT_BRANCH --restart' Enter
  tmux select-window -t backend
"

ssh -t $SSH_STRING "tmux a"
