#!/bin/bash

API_URL="https://api.github.com"

# Ensure GITHUB_TOKEN is set
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "ERROR: GITHUB_TOKEN is not set."
    echo "Run: export GITHUB_TOKEN=\"your_token_here\""
    exit 1
fi

REPO_OWNER=$1
REPO_NAME=$2

github_api_get() {
    local endpoint="$1"
    curl -s -H "Authorization: token $GITHUB_TOKEN" "${API_URL}/${endpoint}"
}

list_users_with_read_access() {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    response=$(github_api_get "$endpoint")

    # If API returns an error message, show it
    if echo "$response" | jq -e 'has("message")' >/dev/null 2>&1; then
        echo "GitHub API error: $(echo "$response" | jq -r '.message')"
        exit 1
    fi

    collaborators=$(echo "$response" | jq -r '.[] | select(.permissions.pull == true) | .login')

    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
