#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
remote="${GITHUB_REMOTE:-origin}"
branch="${GITHUB_BRANCH:-main}"
message="${SNAPSHOT_COMMIT_MESSAGE:-docs: update organization profile snapshot}"

cd "$repo_dir"

if [ ! -f profile/README.md ]; then
  echo "profile/README.md is required before publishing" >&2
  exit 1
fi

tmp_repo="$(mktemp -d)"
trap 'rm -rf "$tmp_repo"' EXIT

rsync -a --exclude .git "$repo_dir"/ "$tmp_repo"/

git -C "$tmp_repo" init -q
git -C "$tmp_repo" checkout -q -b "$branch"
git -C "$tmp_repo" add -A
git -C "$tmp_repo" commit -q -m "$message"
git -C "$tmp_repo" remote add origin "$(git remote get-url "$remote")"
git -C "$tmp_repo" push --force origin "$branch"

git fetch "$remote" "$branch"
git reset --hard "$remote/$branch"
