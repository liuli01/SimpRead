#!/bin/sh
# Copyright 2022 Deta authors. All rights reserved. MIT license.

set -e

matches() {
	input="$1"
	pattern="$2"
	echo "$input" | grep -q "$pattern"
}

supported_architectures="x86_64 arm64 aarch64 aarch64_be armv8b armv8l"

if ! matches "${supported_architectures}" "$(uname -m)"; then
  echo "Error: Unsupported architecture $(uname -m). Only x64 and arm64 binaries are available." 1>&2
	exit 1
fi

if ! command -v unzip >/dev/null; then
	echo "Error: unzip is required to install space cli." 1>&2
	exit 1
fi

case $(uname -m) in
x86_64) target_arch="x86_64" ;;
*) target_arch="arm64" ;;
esac

case $(uname -s) in
Darwin) target_os="darwin" ;;
*) target_os="linux" ;;
esac


if [ $# -eq 0 ]; then
	space_uri="https://ghproxy.com/https://github.com/liuli01/SimpRead/raw/main/deta_space/v0.0.7/space-${target_arch}-${target_os}.zip"
else
	space_uri="https://ghproxy.com/https://github.com/liuli01/SimpRead/raw/main/deta_space/${1}/space-${target_arch}-${target_os}.zip"
fi

space_install="${SPACE_INSTALL:-$HOME/.detaspace}"
bin_dir="$space_install/bin"
exe="$bin_dir/space"

if [ ! -d "$bin_dir" ]; then
	mkdir -p "$bin_dir"
fi

curl --fail --location --progress-bar --output "$exe.zip" "$space_uri"
cd "$bin_dir"
unzip -o "$exe.zip"
chmod +x "$exe"
rm "$exe.zip"

echo "Deta Space CLI was installed successfully to $exe"
if command -v space >/dev/null; then
	echo "Run 'space --help' to get started"
else
	case $SHELL in
	/bin/zsh) shell_profile="$HOME/.zshrc" ;;
	/bin/bash) shell_profile="$HOME/.bashrc" ;;
	*) shell_profile="";;
	esac

	if [ -n "$shell_profile" ]; then
		cp $shell_profile "$shell_profile.bk" 2>/dev/null || true
		echo "" >> "$shell_profile"
		echo "export PATH=\"$bin_dir:\$PATH\"" >> "$shell_profile"	
		echo "Run 'space --help' in a new shell to get started"
    	else
		echo "Manually add $exe to your path:"
		echo "  export PATH=\"$bin_dir:\$PATH\""
		echo " "
		echo "  Run '$exe --help' to get started"
	fi
fi
