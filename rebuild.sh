#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# home.nix's mkOutOfStoreSymlink paths resolve through ~/.dotfiles, so keep the
# link pointing at whatever checkout we were invoked from.
if [ "$DIR" = "$HOME/.dotfiles" ]; then
	: # already in place
elif [ -e ~/.dotfiles ] && [ ! -L ~/.dotfiles ]; then
	echo "==> ~/.dotfiles exists and is not a symlink. Move it aside first."
	exit 1
else
	ln -sfn "$DIR" ~/.dotfiles
fi

# Flakes only see git-tracked files. A forgotten `git add` on a new module
# produces a stale build or a confusing "path does not exist".
if [ -n "$(git -C "$DIR" ls-files --others --exclude-standard)" ]; then
	echo "==> Untracked files present; the flake will ignore them:"
	git -C "$DIR" ls-files --others --exclude-standard | sed 's/^/    /'
	echo "    Run: git add -A"
	exit 1
fi

# sudo may reset PATH to a secure default that excludes /run/current-system/sw/bin,
# so resolve the binary here and invoke the absolute path.
DARWIN_REBUILD="$(command -v darwin-rebuild)"

# "$@" lets you pass --show-trace, or swap switch for build to test without activating.
exec sudo "$DARWIN_REBUILD" switch --flake "$DIR#mac" "$@"
