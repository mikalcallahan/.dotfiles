#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

ICON="$EMAIL"
EMAILS="$(osascript $HOME/.config/sketchybar/scripts/emails.applescript)"
if [[ $EMAILS == "" ]]; then
	ICON=
	COLOR="$CMAGENTA"
elif [[ "$EMAILS" -gt 10 && "$EMAILS" -le 25 ]]; then
	COLOR="$CMAGENTA"
elif [[ "$EMAILS" -gt 25 ]]; then
	COLOR="$CBLUE"
else
	COLOR="$ICON_COLOR"
fi

sketchybar --set $NAME icon=$ICON label="" icon.color=$COLOR
