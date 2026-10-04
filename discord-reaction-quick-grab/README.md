# Discord Reactions Quick Grabber
Opens a `rofi` dmenu containng a list of images inside my Discord reaction images folder. Selected image will be sent to clipboard.

The original one liner got a bit too long

`/bin/ls -1 $HOME/Pictures/Discord\ Reactions/ |
  awk -F'.' '{print $0"\0icon\x1f~/Pictures/Discord Reactions/"$0}' |
  rofi -dmenu -show-icons -matching fuzzy -i -l 5 -p "Filter" -theme-str 'element-icon { size: 10ch ; } ' -font "Noto Sans 12" |
  xargs -I {} wl-copy -t  text/uri-list "file://$(realpath ~/Pictures/Discord\ Reactions/{})"`

## Requirements:
- `rofi`

## Usage:
`./discord-reactions.sh`
