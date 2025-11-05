#!/usr/bin/env bash

# Extract GitHub remote URL from current repo
repo_url=$(git config --get remote.origin.url)

if [ -z "$repo_url" ]; then
    echo "No remote origin found in this repository."
    exit 1
fi

# Optional: Normalize URL (convert git@github.com:... to https://github.com/...)
if [[ $repo_url =~ ^git@github\.com:(.*)\.git$ ]]; then
    repo_url="https://github.com/${BASH_REMATCH[1]}"
elif [[ $repo_url =~ ^https://github\.com/(.*)\.git$ ]]; then
    repo_url="https://github.com/${BASH_REMATCH[1]}"
fi

# Run zen-twilight with the link
zen-twilight "$repo_url"
