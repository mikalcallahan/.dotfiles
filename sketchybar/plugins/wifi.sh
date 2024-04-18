#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"

# CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"
CURRENT_WIFI="$(networksetup -getairportnetwork en0)"
SSID="$(echo "$CURRENT_WIFI" | grep -o ": .*" | sed 's/^: //')"
# CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"
#VPN_STATUS="$(echo 'ivpn status | grep "\bCONNECTED\b"')"
VPN_STATUS=$(/usr/local/bin/ivpn status)
VPN_CONNECTED=$(echo $VPN_STATUS | grep '\bCONNECTED\b')
VPN_PAUSED=$(echo $VPN_STATUS | grep '\bPAUSED\b')
# VPN_CONNECTED="$(ivpn status | grep "\bCONNECTED\b")"
# VPN_PAUSED="$(ivpn status | grep "\bPAUSED\b")"
# IS_VPN=$("scutil --nwi | grep -m1 'utun' | awk '{ print $1 }'")
# VPN_STATUE=false

if [ "$SSID" = "" ]; then
	sketchybar --set $NAME label="Disconnected" icon=睊
else
	if [[ $VPN_CONNECTED =~ "CONNECTED" ]]; then
		sketchybar --set $NAME label="$SSID" icon= icon.color=$ICON_COLOR
	elif [[ $VPN_PAUSED =~ "PAUSED" ]]; then
		sketchybar --set $NAME label="$SSID" icon= icon.color=$ICON_COLOR_WARNING
	else
		sketchybar --set $NAME label="$SSID" icon= icon.color=$ICON_COLOR_ALERT
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
