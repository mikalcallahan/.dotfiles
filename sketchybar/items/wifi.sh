sketchybar --add item wifi right \
	--set wifi script="$PLUGIN_DIR/wifi.sh" \
	background.padding_right=10 \
	update_freq=15 \
	--subscribe wifi wifi_change
