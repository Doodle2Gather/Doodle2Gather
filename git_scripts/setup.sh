#!/usr/bin/env bash

set -o nounset

if [ ! -f ./config.sh ]; then
    echo "Create config.sh first!"
    exit 1
fi

git config filter.xcode_identifiers.smudge "bash git_scripts/set_dynamic_bundle.sh"
git config filter.xcode_identifiers.clean "bash git_scripts/unset_dynamic_bundle.sh"