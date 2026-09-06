#!/usr/bin/env bash

# -e aborts on the first command that returns nonzero
# -u treats reading an unset variable as an error
# pipefail makes a pipeline fail if any stage fails, not just the last one
# without pipefail cat app.log | grep would report success even if cat fails
# -o is how bash turn on named shell options in this case pipefail, +o turn off
set -euo pipefail

# Project Directory
# BASH_SOURCE[0] is the script's own path
# -P resolve symlinks
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" 

echo "==> Step 0: Xcode Command Line Tools"
if xcode-select -p > /dev/null 2>&1; then
	echo "	already installed, skipping"
else
	# --install returns immediately and hands off to a GUI installer,
	# so there's nothing sensible to wait on here.
	xcode-select --install
	echo "	Finish the installer window, then re-run ./bootstrap.sh"
	exit 1
fi

if git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  if [ -n "$(git -C "$DIR" ls-files --others --exclude-standard)" ]; then
    echo "    Untracked files present; flakes ignore them. Run: git add -A"; exit 1
  fi
fi

echo "==> Step 1: Determinate Nix"
if command -v nix > /dev/null 2>&1; then
	echo "	nix already installed, skipping"
else
	# -s silent
	# -S show errors
	# -f fail on HTTP error
	# -L follow redirects
	# sh -s read the script from stdin
	# -- marks end of sh's own options
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
	
	# sourcing so that nix can be used in current session
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# has to exist before the first switch or the build will fail to find them
# -s symbolic
# -f replace an existing entry
# -n without this if ~/.dotfiles already exists as a symlink to a directory ln follows it and creates a link inside that directory instad of replacing it
if [ "$DIR" = "$HOME/.dotfiles" ]; then
  echo "    Repo is already at ~/.dotfiles, nothing to do."
elif [ -e ~/.dotfiles ] && [ ! -L ~/.dotfiles ]; then
  echo "    ~/.dotfiles exists and is not a symlink. Move it aside first."; exit 1
else
  ln -sfn "$DIR" ~/.dotfiles
fi

echo "==> Step 3: personalize the configured username"

# Do this before any sudo call: sudo resets $USER to root, so whoami has to run the real interactive user first
REAL_USER="$(whoami)"

# -n suppresses sed's default line printing
# -E enables extended regex
# pattern -> matches a line of leading whitespace, user = ", then captures everything up to the closing quote
# p prints only the captured group
# head -n1 keeps first match if there are several
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"

if [ -z "$FLAKE_USER" ]; then
  echo "    Could not find the single \"user = \" line in flake.nix."
  echo "    Edit flake.nix yourself before continuing."
  exit 1
elif [ "$FLAKE_USER" != "$REAL_USER" ]; then
  echo "    flake.nix is configured for user \"$FLAKE_USER\", but you are \"$REAL_USER\"."
  read -r -p "    Rewrite flake.nix's \"user = \" line to \"$REAL_USER\"? [y/N] " REPLY || REPLY=n
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    sed -i '' -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
    echo "    Updated. Review the change with: git diff flake.nix"
  else
    echo "    Skipped. Edit the single \"user = \" line in flake.nix yourself before continuing."
    exit 1
  fi
else
  echo "    flake.nix already matches \"$REAL_USER\", nothing to do."
fi


echo "==> Step 4: first darwin-rebuild switch (pinned to nix-darwin-26.05)"
# darwin-rebuild doesn't exist yet on a fresh machine, so run it straight
# from the flake this once. After this, rebuild.sh works normally.
# This fetches the darwin-rebuild tool from the nix-darwin-26.05 release branch,
# not the exact flake.lock revision. The system config it applies is still pinned
# by this repo's flake.lock.
# sudo resets PATH to a secure default that excludes /nix/.../bin, so a
# freshly installed `nix` would not be found under sudo even though it's
# on PATH here. Resolve the absolute path first and invoke that instead.
NIX_BIN="$(command -v nix)"

# "mac" is the flake host label - if you renamed it, change it in flake.nix
# and rebuild.sh too.
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake ~/.dotfiles#mac
# If this still fails with "nix: command not found", open a new terminal
# (Determinate adds nix to new shells' PATH) and re-run ./bootstrap.sh.

echo "==> Done. Use ./rebuild.sh for future changes."

