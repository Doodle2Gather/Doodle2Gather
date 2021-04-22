#!/usr/bin/env bash

localIp=$(ipconfig getifaddr en0)
apiEndpointsPath="../Doodle2Gather/Doodle2Gather/Common/Constants/ApiEndpoints.swift"

echo "Your local IP is: $localIp"

sed -i '' "s/localhost/$localIp/g" $apiEndpointsPath
LC_ALL=C find . -type f -name '*.swift' -exec sed -i '' 's/ApiEndpoints\.Api/ApiEndpoints\.localApi/g' {} +
LC_ALL=C find . -type f -name '*.swift' -exec sed -i '' 's/ApiEndpoints\.WS/ApiEndpoints\.localWS/g' {} +
