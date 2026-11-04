#!/usr/bin/env bash
set -euo pipefail

config_file=$1
seed_file=$2
kwriteconfig=$3

# A regular file belongs to Kdenlive. Never reset its GUI preferences.
if [[ -e "$config_file" && ! -L "$config_file" ]]; then
    exit 0
fi

mkdir -p -- "$(dirname -- "$config_file")"
source_file=$seed_file
if [[ -L "$config_file" ]]; then
    # Dereference the link: the backup must survive Nix store garbage collection.
    # A missing/unreadable target aborts here, leaving the link untouched.
    backup_file=$(mktemp "$config_file.before-github-dark-studio.XXXXXX")
    cp -L -- "$config_file" "$backup_file"
    source_file=$backup_file
    printf 'Kdenlive settings backed up to %s\n' "$backup_file"
fi

# Replace atomically, only after both the backup and the writable copy succeed.
temp_file=$(mktemp "$config_file.tmp.XXXXXX")
trap 'rm -f -- "$temp_file"' EXIT
cp -- "$source_file" "$temp_file"
chmod 600 -- "$temp_file"

# Verified in Kdenlive 26.04.3, src/utils/thememanager.cpp: loadCurrentPath()
# and schemeActionTriggered() use this key and the scheme's filename.
"$kwriteconfig" --file "$temp_file" --group UiSettings \
    --key ColorSchemePath GitHubDarkStudio.colors
mv -T -- "$temp_file" "$config_file"
