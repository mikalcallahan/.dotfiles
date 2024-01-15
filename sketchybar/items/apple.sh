#!/usr/bin/env sh

POPUP_OFF="sketchybar --set apple.logo popup.drawing=off"
POPUP_CLICK_SCRIPT="sketchybar --set \$NAME popup.drawing=toggle"

sketchybar --add item apple.logo left \
	--set apple.logo icon=$APPLE \
	icon.color=$CWHITE \
	background.padding_right=25 \
	label.drawing=off \
	popup.height="50" \
	click_script="$POPUP_CLICK_SCRIPT" \
	\
	--add item apple.activity popup.apple.logo \
	--set apple.activity icon=$ACTIVITY \
	label="Activity" \
	label.font="$FONT:Regular:13" \
	background.padding_right=25 \
	background.padding_left=25 \
	y_offset="-5" \
	click_script="open -a 'Activity Monitor';
                                              $POPUP_OFF" \
	\
	--add item apple.lock popup.apple.logo \
	--set apple.lock icon=$LOCK \
	label="Lock Screen" \
	label.font="$FONT:Regular:13" \
	background.padding_right=25 \
	background.padding_left=25 \
	y_offset="0" \
	click_script="pmset displaysleepnow;
                                              $POPUP_OFF" \
	--add item apple.prefs popup.apple.logo \
	--set apple.prefs icon=$PREFERENCES \
	label="Preferences" \
	label.font="$FONT:Regular:13" \
	background.padding_right=25 \
	background.padding_left=25 \
	y_offset="5" \
	click_script="open -a 'System Preferences';
                                              $POPUP_OFF" \
	\
	--add item apple.restart popup.apple.logo \
	--set apple.restart icon=$RESTART \
	label="Restart" \
	label.font="$FONT:Regular:13" \
	background.padding_right=25 \
	background.padding_left=25 \
	y_offset="8" \
	click_script="osascript -e 'tell app \"loginwindow\" to «event aevtrrst»';
                                              $POPUP_OFF" \
	--add item apple.shutdown popup.apple.logo \
	--set apple.shutdown icon=$SHUTDOWN \
	label="Shutdown" \
	label.font="$FONT:Regular:13" \
	background.padding_right=80 \
	background.padding_left=25 \
	y_offset="10" \
	click_script="osascript -e 'tell app \"loginwindow\" to «event aevtrsdn»';
                                              $POPUP_OFF"
