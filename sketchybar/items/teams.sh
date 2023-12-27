sketchybar --add item teams right \
	--set teams \
	update_freq=60 \
	script="$PLUGIN_DIR/teams.sh" \
	background.padding_left=10 \
	icon.font.size=18 \
	--subscribe teams system_woke
