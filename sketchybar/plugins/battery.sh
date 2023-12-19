#!/usr/bin/env sh

source "$HOME/.config/sketchybar/icons.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')
LABEL=""

if [ $PERCENTAGE = "" ]; then
	exit 0
fi

case ${PERCENTAGE} in
9[0-9] | 100)
	LABEL="${PERCENTAGE}%" ICON="$BATTERY_4"

	if [[ $CHARGING != "" ]]; then
		LABEL="${PERCENTAGE}%" ICON="$BATTERY_4_CHARGING"
	fi
	;;
[6-8][0-9])
	LABEL="${PERCENTAGE}%" ICON="$BATTERY_3"

	if [[ $CHARGING != "" ]]; then
		LABEL="${PERCENTAGE}%" ICON="$BATTERY_3_CHARGING"
	fi
	;;
[3-5][0-9])
	LABEL="${PERCENTAGE}%" ICON="$BATTERY_2"

	if [[ $CHARGING != "" ]]; then
		LABEL="${PERCENTAGE}%" ICON="$BATTERY_2_CHARGING"
	fi

	;;
[1-2][0-9])
	LABEL="${PERCENTAGE}%" ICON="$BATTERY_1"

	if [[ $CHARGING != "" ]]; then
		LABEL="${PERCENTAGE}%" ICON="$BATTERY_1_CHARGING"
	fi
	;;
*)
	LABEL="${PERCENTAGE}%" ICON="$BATTERY_0"
	if [[ $CHARGING != "" ]]; then
		LABEL="${PERCENTAGE}%" ICON="$BATTERY_0_CHARGING"
	fi
	;;
esac

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
# sketchybar --set $NAME icon="$ICON" label="${PERCENTAGE}%"
sketchybar --set $NAME label=$LABEL icon="$ICON"
