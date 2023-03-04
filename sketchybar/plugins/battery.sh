#!/usr/bin/env sh

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')
LABEL=""

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

case ${PERCENTAGE} in
  9[0-9]|100) LABEL="${PERCENTAGE}%" ICON="􀛨" 
  # 9[0-9]|100) LABEL="${PERCENTAGE}%" ICON="" 
  ;;
  [6-8][0-9]) LABEL="${PERCENTAGE}%" ICON="􀺸" 
  #[6-8][0-9]) LABEL="${PERCENTAGE}%" ICON="" 
  ;;
  #[3-5][0-9]) LABEL="${PERCENTAGE}%" ICON="" 
  [3-5][0-9]) LABEL="${PERCENTAGE}%" ICON="􀺶" 
  ;;
  # [1-2][0-9]) LABEL="${PERCENTAGE}%" ICON="" 
  [1-2][0-9]) LABEL="${PERCENTAGE}%" ICON="􀛩" 
  ;;
  *) LABEL="${PERCENTAGE}%" ICON="􀛪" 
  #*) LABEL="${PERCENTAGE}%" ICON="" 
esac

if [[ $CHARGING != "" ]]; then
  ICON="􀢋"
  LABEL="${PERCENTAGE}%"
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
# sketchybar --set $NAME icon="$ICON" label="${PERCENTAGE}%"
sketchybar --set $NAME label=$LABEL icon="$ICON"
