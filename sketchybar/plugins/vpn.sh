#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

STATUS=$(ivpn status | grep "\bCONNECTED\b" | wc -l)

if [[ $STATUS != 0 ]]; then
	sketchybar --set $NAME icon= label=$STATUS
else
	sketchybar --set $NAME icon= label=$STATUS
fi

