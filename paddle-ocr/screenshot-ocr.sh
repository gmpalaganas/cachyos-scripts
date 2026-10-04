#!/usr/bin/env bash
#
# screenshot-ocr.sh
# Screenshot a region with Spectacle, OCR it with PaddleOCR, and copy
# the extracted text to the clipboard (Wayland via wl-copy).
#
# Requires: spectacle, wl-copy, notify-send, ocr_cli.py + paddleocr venv

set -uo pipefail

# --- Config -------------------------------------------------------------

OCR_DIR="$HOME/.local/bin/paddle-ocr"
VENV="$OCR_DIR/.venv/"
OCR_SCRIPT="$OCR_DIR/ocr_cli.py"

TMP_DIR="$(mktemp -d /tmp/spectacle-ocr.XXXXXX)"
IMG_PATH="$TMP_DIR/shot.png"
OCR_LOG="$TMP_DIR/ocr_stderr.log"

APP_NAME="Screenshot OCR"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Arguments:
# $1 Message heading
# $2 Message body
# $3 Message icon (see: https://specifications.freedesktop.org/icon-naming/latest/ for valid icons)
notify() {
  notify-send -a "$APP_NAME" --icon=$3 "$APP_NAME" "<b>$1</b>\n$2"
}

# --- 1. Take the screenshot ------------------------------------------------

# -b background (no spectacle window/flash), -n no notification from spectacle,
# -r region select, -o output file
spectacle -b -n -r -o "$IMG_PATH"

# If the user hit Escape/cancelled the selection, no file is written.
if [[ ! -s "$IMG_PATH" ]]; then
  notify "OCR Cancelled" "Screenshot cancelled" "dialog-error"
  exit 0
fi

# --- 2. Run PaddleOCR via uv run ---------------------------------

if [[ ! -d "$VENV" ]]; then
  notify "OCR Failed" "venv not found at $VENV" "dialog-error"
  exit 1
fi

if [[ ! -f "$OCR_SCRIPT" ]]; then
  notify "OCR Failed" "Script not found at $OCR_SCRIPT" "dialog-error"
  exit 1
fi

EXTRACTED_TEXT="$(uv --directory "$OCR_DIR" run "$OCR_SCRIPT" "$IMG_PATH" 2>"$OCR_LOG")"
OCR_EXIT=$?

# --- 3. Send to clipboard / notify -------------------------------------------

if [[ $OCR_EXIT -ne 0 ]]; then
  if [[ -s "$OCR_LOG" ]]; then
    notify "OCR failed" "No text detected (see log: $OCR_LOG)" "dialog-error"
  else
    notify "OCR failed" "No text detected" "dialog-error"
  fi
  exit 1
fi

printf '%s' "$EXTRACTED_TEXT" | wl-copy
notify "OCR success" "Text sent to clipboard" "edit-copy"
paplay /usr/share/sounds/ocean/stereo/completion-success.oga
exit 0
