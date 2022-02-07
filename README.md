# TUNA Nixpkgs channel mirror

Takes the channels from the TUNA mirror of Nixpkgs (<https://mirrors.tuna.tsinghua.edu.cn/nix-channels/>) and puts them in other branches in this repo.

## Usage

To run `nix` from TUNA mirror's channel `nixos-unstable`:

```
$ nix run github:tuna-nixpkgs/nixpkgs/nixos-unstable#nix
```

## Details

Updates are run *every hour*.

Channels on the TUNA mirrors are updated only when the closure is downloaded into binary cache. Moreover, if a channel updates slightly too fast, some channel versions might not be available on TUNA. This means that if you use the TUNA mirror binary cache (<https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store>), you might want to follow TUNA's channels.

However, Nix Flakes don't really work well with channels served over HTTP(S). Well, here's your workaround.

The file contents and commit hashes here are identical to that of the official Nixpkgs repo. The only difference is where the branches point to.
