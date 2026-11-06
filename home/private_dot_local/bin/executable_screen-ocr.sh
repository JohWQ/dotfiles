#!/usr/bin/env bash
set -euo pipefail

region=$(slurp) || exit 0
[[ -n "$region" ]] || exit 0

if ! text=$(grim -g "$region" - | tesseract stdin stdout -l eng+nor); then
    notify-send "OCR failed" "Could not capture or recognize the selected region."
    exit 1
fi

if [[ ! "$text" =~ [^[:space:]] ]]; then
    notify-send "OCR" "No text detected."
    exit 0
fi

printf '%s' "$text" | wl-copy --type text/plain
printf '%s\n' "$text"
notify-send "OCR — Copied to clipboard" "$text"
