#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

ICON="$EMAIL"
LABEL="$(osascript $HOME/.config/sketchybar/scripts/emails.applescript)"
if [[ $LABEL == "" ]]; then
	ICON=
	COLOR="$CMAGENTA"
elif [[ "$LABEL" -gt 10 && "$LABEL" -le 25 ]]; then
	COLOR="$CMAGENTA"
elif [[ "$LABEL" -gt 25 ]]; then
	COLOR="$CBLUE"
else
	COLOR="$ICON_COLOR"
fi

sketchybar --set $NAME icon=$ICON label="${LABEL}" icon.color=$COLOR
