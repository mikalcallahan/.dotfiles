#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"

OS_VERSION="$(sw_vers | grep 'ProductVersion' | awk -F'[ .:]+' '{print $2}' | xargs)"

if [ "$OS_VERSION" -gt "14" ]; then
  IP_ADDRESS="$(networksetup -getinfo "Wi-Fi" | grep "IP address" | awk -F ': ' '{print $2}' | awk 'NR==1')"
  SSID="$IP_ADDRESS"
else
  CURRENT_WIFI="$(networksetup -getairportnetwork en0)"
  # CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"
  SSID="$(echo "$CURRENT_WIFI" | grep -o ": .*" | sed 's/^: //')"
fi

VPN_STATUS=$(/usr/local/bin/ivpn status)
VPN_CONNECTED=$(echo "$VPN_STATUS" | grep '\bCONNECTED\b')
VPN_PAUSED=$(echo "$VPN_STATUS" | grep '\bPAUSED\b')

if [ "$SSID" = "" ]; then
  sketchybar --set "$NAME" label="Disconnected" icon=睊
elif [ "$VPN_STATUS" = "" ]; then
  sketchybar --set $NAME label="$SSID" icon= icon.color=$ICON_COLOR
else
  if [[ $VPN_CONNECTED =~ "CONNECTED" ]]; then
    sketchybar --set "$NAME" label="$SSID" icon= icon.color="$ICON_COLOR"
  elif [[ $VPN_PAUSED =~ "PAUSED" ]]; then
    sketchybar --set "$NAME" label="$SSID" icon= icon.color="$ICON_COLOR_WARNING"
  else
    sketchybar --set "$NAME" label="$SSID" icon= icon.color="$ICON_COLOR_ALERT"
  fi
fi
