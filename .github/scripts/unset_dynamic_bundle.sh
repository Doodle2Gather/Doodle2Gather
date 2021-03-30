#!/usr/bin/env bash

#  unset_dynamic_bundle.sh
#  Doodle2Gather
#
#  Created by Christopher Goh on 9/3/21.
#

set -o nounset
. .github/scripts/config.sh

sed "s/DEVELOPMENT_TEAM = $NEW_DEV_TEAM;/DEVELOPMENT_TEAM = $ORIGINAL_DEV_TEAM;/g" | sed "s/PRODUCT_BUNDLE_IDENTIFIER = $NEW_BUNDLE_ID;/PRODUCT_BUNDLE_IDENTIFIER = $ORIGINAL_BUNDLE_ID;/g"
