#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"


COUNT=$(brew outdated | wc -l | tr -d ' ')

COLOR=$RED

case "$COUNT" in
  [3-5][0-9]) sketchybar --set $NAME label=$COUNT icon.color=$ORANGE icon=$PACKAGE
  ;;
  [1-2][0-9]) sketchybar --set $NAME label=$COUNT icon.color=$YELLOW icon=$PACKAGE
  ;;
  [1-9]) sketchybar --set $NAME label=$COUNT icon.color=$WHITE icon=$PACKAGE
  ;;
  0) COLOR=
     COUNT=
     sketchybar --set $NAME label= icon.color= icon=
  ;;
esac

# sketchybar --set $NAME label=$COUNT icon.color=$COLOR icon=$PACKAGE
