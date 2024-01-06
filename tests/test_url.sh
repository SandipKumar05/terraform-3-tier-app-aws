#!/bin/bash

# bash test_url.sh url1 url2 ..
# ex: bash test_url.sh www.google.com www.amazon.com
api_url="www.google.com"
web_url="www.amazon.com"
url_to_test=($api_url $web_url)

for url in ${url_to_test[@]}; do
    curl -sSf "$url" > /dev/null

    if [ $? -eq 0 ]; then
        echo "$url is reachable."
    else
        echo "$url is not reachable."
        exit 1
    fi
done