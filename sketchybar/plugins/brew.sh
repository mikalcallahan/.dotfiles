#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

COUNT=$(brew outdated | wc -l | tr -d ' ')

COLOR=$RED
LABEL=""

case "$COUNT" in
[3-5][0-9])
	sketchybar --set $NAME label=$LABEL icon.color=$ORANGE icon=$PACKAGE
	;;
[1-2][0-9])
	sketchybar --set $NAME label=$LABEL icon.color=$ICON_COLOR_ALERT icon=$PACKAGE
	;;
[1-9])
	sketchybar --set $NAME label=$LABEL icon.color=$ICON_COLOR_WARNING icon=$PACKAGE
	;;
0)
	COLOR=$RED
	COUNT=
	sketchybar --set $NAME label=$LABEL icon.color=$ICON_COLOR icon=$PACKAGE
	;;
esac

# sketchybar --set $NAME label=$COUNT icon.color=$COLOR icon=$PACKAGE
