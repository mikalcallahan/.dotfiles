#!/usr/bin/env sh

#CLICK_SCRIPT=$(osascript -e 'tell application "System Events" to key code 111')

sketchybar --add item calendar right \
	--set calendar icon.font="$FONT:0xff$CFORE:12.0" \
	icon.padding_right=0 \
	label.width=50 \
	label.align=right \
	background.padding_left=10 \
	update_freq=15 \
	script="$PLUGIN_DIR/calendar.sh" \
	\
	--subscribe calendar system_woke # click_script="$CLICK_SCRIPT" \
# click_script="$PLUGIN_DIR/zen.sh" # click_script="$CLICK_SCRIPT" \
