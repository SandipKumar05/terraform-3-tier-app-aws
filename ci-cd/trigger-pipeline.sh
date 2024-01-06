#!/bin/bash
set -x
username="SandipKumar05"
repo="ci-cd"
token=$1

curl --request POST \
     --header "Authorization: token $token" \
     --header "Accept: application/vnd.github+json" \
     --data '{"event_type": "Pipeline"}' \
     "https://api.github.com/repos/$username/$repo/dispatches"

echo "Check latest pipeline:- https://api.github.com/repos/$username/$repo/actions"