#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"

CLICK_SCRIPT="osascript -e 'tell application \"System Events\" to key code 111'"

sketchybar --add item calendar right \
	--set calendar icon.font="$FONT:Semibold:12.0" \
	icon.color="$ICON_COLOR" \
	icon.padding_right=0 \
	label.width=50 \
	label.align=right \
	background.padding_left=10 \
	update_freq=15 \
	click_script="$CLICK_SCRIPT" \
	script="$PLUGIN_DIR/calendar.sh" \
	\
	--subscribe calendar system_woke
