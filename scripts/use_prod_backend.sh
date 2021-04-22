#!/usr/bin/env bash

localIp=$(ipconfig getifaddr en0)
apiEndpointsPath="../Doodle2Gather/Doodle2Gather/Common/Constants/ApiEndpoints.swift"

sed -i '' "s/$localIp/localhost/g" $apiEndpointsPath
LC_ALL=C find . -type f -name '*.swift' -exec sed -i '' 's/ApiEndpoints\.localApi/ApiEndpoints\.Api/g' {} +
LC_ALL=C find . -type f -name '*.swift' -exec sed -i '' 's/ApiEndpoints\.localWS/ApiEndpoints\.WS/g' {} +
