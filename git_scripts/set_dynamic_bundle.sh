#!/usr/bin/env sh

#  set_dynamic_bundle.sh
#  Doodle2Gather
#
#  Created by Christopher Goh on 9/3/21.
#  

ORIGINAL_DEV_TEAM="K9H85859Q4"
NEW_DEV_TEAM="7E2G8573A5"
ORIGINAL_BUNDLE_ID="com.hanmingdev.Doodle2Gather"
NEW_BUNDLE_ID="sg.christopher.d2g"

sed "s/DEVELOPMENT_TEAM = $ORIGINAL_DEV_TEAM;/DEVELOPMENT_TEAM = $NEW_DEV_TEAM;/g"
sed "s/PRODUCT_BUNDLE_IDENTIFIER = $ORIGINAL_BUNDLE_ID;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_BUNDLE_ID;/g"