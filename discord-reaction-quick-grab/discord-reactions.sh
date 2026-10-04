#!/usr/bin/env bash
#
# discord-reaction-picker.sh
#
# Shows a rofi menu (with icon previews) of all images in your
# "Discord Reactions" folder, and copies the chosen file's URI
# to the clipboard (as text/uri-list) so you can paste it into Discord.

set -euo pipefail

REACTIONS_DIR="$HOME/Pictures/Discord Reactions"
ROFI_THEME="$HOME/.local/bin/discord-tools/discord-reactions-theme.rasi"

# Rofi theme override:
#   - window background set to ROFI_BG_COLOR
#   - text and border color set to ROFI_FG_COLOR everywhere
#   - icon size set to ROFI_ICON_SIZE

# Make sure the folder actually exists before we do anything else.
if [[ ! -d "$REACTIONS_DIR" ]]; then
  echo "Error: '$REACTIONS_DIR' does not exist." >&2
  exit 1
fi

if [[ ! -f "$ROFI_THEME" ]]; then
  echo "Error: '$ROFI_THEME' does not exist." >&2
fi

# Build the rofi menu entries.
#
# rofi's -show-icons mode expects each line in the form:
#   <display text>\0icon\x1f<path to icon>
#
# We use awk to turn each filename into that format, pointing the
# icon path at the file itself (since these are all images).
build_menu_entries() {
  /bin/ls -1 "$REACTIONS_DIR" | awk -F'.' -v dir="$REACTIONS_DIR" '{
        print $0 "\0icon\x1f" dir "/" $0
    }'
}

# Show the rofi picker and print whatever the user selected.
show_picker() {
  build_menu_entries | rofi \
    -dmenu \
    -show-icons \
    -matching fuzzy \
    -i \
    -theme "$ROFI_THEME"
}

# Copy the chosen file's URI to the clipboard as text/uri-list.
copy_selection_to_clipboard() {
  local selected="$1"
  local full_path

  # Bail out quietly if the user pressed Escape / selected nothing.
  [[ -z "$selected" ]] && exit 0

  # realpath is there to auto-resolve symlinks just in case
  full_path="$(realpath "$REACTIONS_DIR/$selected")"
  wl-copy -t text/uri-list "file://$full_path"
}

main() {
  local selection
  selection="$(show_picker)"
  copy_selection_to_clipboard "$selection"
}

main
