#!/usr/bin/env bash

set -euo pipefail

if ! command -v desktop-file-edit >/dev/null 2>&1; then
  echo 'desktop-file-edit is required (install desktop-file-utils).' >&2
  exit 1
fi

# Directories containing .desktop files
USER_APPS="$HOME/.local/share/applications"
SYSTEM_APPS="/usr/share/applications"

# Check if arguments were passed
if [ "$#" -gt 0 ]; then
  SELECTED_FILES=("$@")
else
  # Collect .desktop files, excluding those that already contain NoDisplay=true
  mapfile -t SELECTED_FILES < <(
    fd -e desktop -d 1 . "$USER_APPS" "$SYSTEM_APPS" | \
    xargs -r grep -L "^NoDisplay=true" | \
    fzf -m \
        --prompt="Select .desktop files > " \
        --header="Tab: select multiple | Enter: confirm" \
        --preview='cat {}' \
        --preview-window=right:60%
  )
fi

# Exit if no files were selected
if [ ${#SELECTED_FILES[@]} -eq 0 ]; then
  echo "No files selected."
  echo -e 'To show hidden desktop entries run:\n$ fd -e desktop -d 1 . /usr/share/applications ~/.local/share/applications | xargs -r grep -l "^NoDisplay=true"'
  exit 0
fi

mkdir -p "$USER_APPS"

for FILE in "${SELECTED_FILES[@]}"; do
  # Exit immediately if an invalid file path is passed
  if [ ! -f "$FILE" ]; then
    echo -e "Error: File not found: $FILE\nProvide filename argument, or none at all." >&2
    echo -e 'To show hidden desktop entries run:\n$ fd -e desktop -d 1 . /usr/share/applications ~/.local/share/applications | xargs -r grep -l "^NoDisplay=true"'
    exit 1
  fi

  # Ask confirmation if the file does not end with .desktop
  if [[ "$FILE" != *.desktop ]]; then
    read -rp "Warning: '$FILE' does not end with \".desktop\". Continue anyway? [y/N] " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
      echo "Skipping $FILE."
      echo -e 'To show hidden desktop entries run:\n$ fd -e desktop -d 1 . /usr/share/applications ~/.local/share/applications | xargs -r grep -l "^NoDisplay=true"'
      continue
    fi
  fi

  TARGET_FILE="$FILE"

  # Copy system files to user directory if not writable
  if [[ "$FILE" == "$SYSTEM_APPS"* ]] && [ ! -w "$FILE" ]; then
    BASENAME=$(basename "$FILE")
    TARGET_FILE="$USER_APPS/$BASENAME"
    
    if [ ! -f "$TARGET_FILE" ]; then
      cp "$FILE" "$TARGET_FILE"
      echo "Copied $(basename "$FILE") to ~/.local/share/applications/"
      echo -e 'To show hidden desktop entries run:\n$ fd -e desktop -d 1 . /usr/share/applications ~/.local/share/applications | xargs -r grep -l "^NoDisplay=true"'
    fi
  fi

  # Update only the main [Desktop Entry] group, preserving action groups.
  desktop-file-edit --set-key=NoDisplay --set-value=true "$TARGET_FILE"

  echo "Hidden desktop entry: $TARGET_FILE"
  echo -e 'To show hidden desktop entries run:\n$ fd -e desktop -d 1 . /usr/share/applications ~/.local/share/applications | xargs -r grep -l "^NoDisplay=true"'
done
