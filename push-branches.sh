#!/usr/bin/env bash

set -eo pipefail

BASE_URL="https://mirrors.tuna.tsinghua.edu.cn/nix-channels"
UPSTREAM_REPO="https://github.com/NixOS/nixpkgs.git"
MIRROR_REPO="https://github.com/$GITHUB_REPOSITORY"

builtin echo "machine github.com login dramforever password $TOKEN_WORKFLOW"> ~/.netrc

get_mirror_branches() {
    curl -sSL "$BASE_URL/" | sed -Ee '
        s/.* title="(nix(os|pkgs)-[a-z0-9.-]+)">.*/\1/p
        d
    ' | while IFS= read -r channel; do
        git_revision="$(curl -sSL "$BASE_URL/$channel/git-revision")"
        echo "$git_revision\t$channel"
    done
}

get_current_branches() {
    git ls-remote "$MIRROR_REPO" "refs/heads/*" | sed "s|refs/heads/||g"
}

# Don't mess up my token please
git config --unset --local http.https://github.com/.extraheader

join -j2 \
    <(get_mirror_branches | sort -k1) \
    <(get_current_branches | sort -k2) \
    | while IFS=$'\t' read -r channel mirror_rev current_rev; do

    if [ "$mirror_rev" != "$current_rev" ]; then
        echo "Updating $channel" >&2
        echo "  $current_rev -> $mirror_rev" >&2

        git fetch "$UPSTREAM_REPO" "$channel"
        git push "$MIRROR_REPO" "$mirror_rev:refs/heads/$channel"
    fi
done
