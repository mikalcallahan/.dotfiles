#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"

CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"
SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //')"
CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"
VPN_STATUS=$(echo ivpn status | grep "\bCONNECTED\b" | wc -l)

if [ "$SSID" = "" ]; then
  sketchybar --set $NAME label="Disconnected" icon=睊
else
  if [[ $STATUS != 0 ]]; then
    sketchybar --set $NAME label="$SSID" icon= icon.color=$GREEN
    # sketchybar --set $NAME label="$SSID (${CURR_TX}Mbps)" icon=直
  else
    sketchybar --set $NAME label="$SSID" icon= icon.color=$ORANGE
  fi
fi
