#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

STATUS_LABEL=$(lsappinfo info -only StatusLabel "Microsoft Teams classic")
ICON="$TEAMS"

if [[ $STATUS_LABEL =~ \"label\"=\"([^\"]*)\" ]]; then
    LABEL="${BASH_REMATCH[1]}"

    if [[ $LABEL == "" ]]; then
        ICON_COLOR="$CMAGENTA"
    elif [[ $LABEL == "•" ]]; then
        ICON_COLOR="$CMAGENTA"
    elif [[ $LABEL =~ ^[0-9]+$ ]]; then
        ICON_COLOR="$WHITE"
    else
        exit 0
    fi
else
  exit 0
fi

sketchybar --set $NAME icon=${ICON} label="${LABEL}" icon.color=$ICON_COLOR
