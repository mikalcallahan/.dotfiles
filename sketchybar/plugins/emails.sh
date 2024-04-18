#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

ICON="$EMAIL"
EMAILS="$(osascript $HOME/.config/sketchybar/scripts/emails.applescript)"
if [[ $EMAILS == "" ]]; then
	ICON=
	COLOR="$ICON_COLOR"
elif [[ "$EMAILS" -gt 10 && "$EMAILS" -le 25 ]]; then
	COLOR="$ICON_COLOR_WARNING"
elif [[ "$EMAILS" -gt 25 ]]; then
	COLOR="$ICON_COLOR_ALERT"
else
	COLOR="$ICON_COLOR"
fi

sketchybar --set $NAME icon=$ICON label="" icon.color=$COLOR
