#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"

CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"
SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //')"
CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"
# VPN_STATUS="$(ivpn status | grep "\bCONNECTED\b")"
IS_VPN=$(scutil --nwi | grep -m1 'utun' | awk '{ print $1 }')
# VPN_STATUE=false

if [ "$SSID" = "" ]; then
	sketchybar --set $NAME label="Disconnected" icon=睊
else
	# if [[ $VPN_STATUS =~ "CONNECTED" ]]; then
	if [[ $IS_VPN != "" ]]; then
		sketchybar --set $NAME label="$SSID" icon= icon.color=$CGREEN
		# sketchybar --set $NAME label="$SSID (${CURR_TX}Mbps)" icon=直
	else
		sketchybar --set $NAME label="$SSID" icon= icon.color=$CBLUE
	fi
fi

# IP_ADDRESS=$(scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1)
# IS_VPN=$(scutil --nwi | grep -m1 'utun' | awk '{ print $1 }')
#
# if [[ $IS_VPN != "" ]]; then
# 	COLOR=$CYAN
# 	ICON=
# 	LABEL="VPN"
# elif [[ $IP_ADDRESS != "" ]]; then
# 	COLOR=$BLUE
# 	ICON=
# 	LABEL=$IP_ADDRESS
# else
# 	COLOR=$WHITE
# 	ICON=
# 	LABEL="Not Connected"
# fi
#
# sketchybar --set $NAME \
# 	icon=$ICON \
# 	label="$LABEL"
