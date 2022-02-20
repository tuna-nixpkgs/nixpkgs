#!/usr/bin/env bash

set -eo pipefail

BASE_URL="https://mirrors.tuna.tsinghua.edu.cn/nix-channels"
UPSTREAM_REPO="https://github.com/NixOS/nixpkgs.git"
MIRROR_REPO="https://github.com/$GITHUB_REPOSITORY"

builtin echo "machine github.com login dramforever password $TOKEN_WORKFLOW"> ~/.netrc

curl -sSL "$BASE_URL/" | sed -Ee '
    s/.* title="(nix(os|pkgs)-[a-z0-9.-]+)">.*/\1/p
    d
' | while IFS= read -r channel; do
    echo "Updating $channel" >&2
    git_revision="$(curl -sSL "$BASE_URL/$channel/git-revision")"
    echo "  -> Git revision = $git_revision" >&2

    git fetch "$UPSTREAM_REPO" "$channel"
    git push "$MIRROR_REPO" "$git_revision:refs/heads/$channel"
done
