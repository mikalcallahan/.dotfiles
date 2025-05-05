#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

update_icon_color() {
    local label="$1"
    if [[ $label == "" ]]; then
        ICON_COLOR="$ICON_COLOR"  # Presumably, default color is already set in colors.sh
    elif [[ $label == "•" || $label =~ ^[0-9]+$ ]]; then
        ICON_COLOR="$ICON_COLOR_ALERT"
    else
        ICON_COLOR="$ICON_COLOR_WARNING"
        exit 0
    fi
}

# Main script logic
STATUS_LABEL=$(lsappinfo info -only StatusLabel "Microsoft Teams")
STATUS_LABEL="${STATUS_LABEL%"${STATUS_LABEL##*[![:space:]]}"}"  # Trim trailing whitespace

ICON="$TEAMS"
CLOSED_LABEL='"StatusLabel"=[ NULL ]'
NULL_LABEL='"StatusLabel"={ "label"=kCFNULL }'
NON_EMPTY_LABEL='"StatusLabel"={ "label"="1" }'

if [[ $STATUS_LABEL =~ \"label\"=\"([^\"]*)\" ]]; then
    LABEL="${BASH_REMATCH[1]}"
    update_icon_color "$LABEL"
elif [[ "$STATUS_LABEL" == "$NULL_LABEL" || "$STATUS_LABEL" == "$CLOSED_LABEL" ]]; then
    ICON_COLOR="$ICON_COLOR"  # Set to default color if status label matches NULL or CLOSED
else
   exit 0
fi

sketchybar --set $NAME icon=${ICON} icon.color=$ICON_COLOR
