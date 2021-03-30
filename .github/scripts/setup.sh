#!/usr/bin/env bash

set -o nounset

if [ ! -f ./config.sh ]; then
    echo "Create config.sh first!"
    exit 1
fi

git config filter.xcode_identifiers.smudge "bash .github/scripts/set_dynamic_bundle.sh"
git config filter.xcode_identifiers.clean "bash .github/scripts/unset_dynamic_bundle.sh"