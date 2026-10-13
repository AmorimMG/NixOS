#!/usr/bin/env bash
# Refresh pkgs/craft/_sources/generated.json from the latest GitHub releases.
# GitHub publishes a sha256 digest per release asset, so no tarball is downloaded.
set -euo pipefail

file="$(dirname "$(readlink -f "$0")")/_sources/generated.json"
tmp=$(mktemp)
trap 'rm -f "$tmp" "$tmp.new"' EXIT
cp "$file" "$tmp"

for app in $(jq -r 'keys[]' "$file"); do
  rel=$(gh api "repos/storytold/$app/releases/latest")
  tag=$(jq -r .tag_name <<<"$rel")
  ver="${tag#v}"
  name="$app-$ver-linux-x86_64.tar.gz"
  hex=$(jq -r --arg n "$name" '.assets[] | select(.name==$n) | .digest' <<<"$rel" | sed 's/^sha256://')
  [[ -n "$hex" ]] || { echo "No digest for $name" >&2; exit 1; }
  sri=$(nix hash convert --hash-algo sha256 --to sri "$hex")
  jq --arg a "$app" --arg v "$ver" --arg h "$sri" \
    --arg u "https://github.com/storytold/$app/releases/download/$tag/$name" \
    '.[$a].version=$v | .[$a].src.sha256=$h | .[$a].src.url=$u' "$tmp" >"$tmp.new"
  mv "$tmp.new" "$tmp"
done
cp "$tmp" "$file"
