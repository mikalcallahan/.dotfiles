#!/usr/bin/env sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# sketchybar --set $NAME label="$INFO"

FRONT_APP_SCRIPT='sketchybar --set $NAME label="$INFO"'

sketchybar --add event window_focus \
	--add event windows_on_spaces \
	--add item system.yabai left \
	--set system.yabai script="$PLUGIN_DIR/yabai.sh" \
	icon.font="$FONT:Regular:15.0" \
	label.drawing=off \
	icon.width=30 \
	icon=$YABAI_GRID \
	icon.color=$CGREEN \
	updates=on \
	associated_display=active \
	--subscribe system.yabai window_focus \
	windows_on_spaces \
	mouse.clicked \
	\
	--add item front_app left \
	--set front_app script="$FRONT_APP_SCRIPT" \
	icon.drawing=off \
	background.padding_left=0 \
	background.padding_right=10 \
	label.color=$CWHITE \
	label.font="$FONT:Semibold:12.0" \
	associated_display=active \
	--subscribe front_app front_app_switched
