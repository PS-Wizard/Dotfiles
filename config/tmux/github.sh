#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a Git repository."
    exit 1
fi

repo_url=$(git remote get-url origin 2>/dev/null || true)
if [ -z "$repo_url" ]; then
    echo "No remote origin found in this repository."
    exit 1
fi

if [[ $repo_url =~ ^git@github\.com:(.*?)(\.git)?$ ]]; then
    repo_url="https://github.com/${BASH_REMATCH[1]}"
elif [[ $repo_url =~ ^https://github\.com/(.*?)(\.git)?$ ]]; then
    repo_url="https://github.com/${BASH_REMATCH[1]}"
else
    echo "Origin is not a GitHub remote: $repo_url"
    exit 1
fi

if command -v zen-browser >/dev/null 2>&1; then
    exec zen-browser "$repo_url"
fi

exec xdg-open "$repo_url"
