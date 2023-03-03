#!/usr/bin/env sh

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8")
SPACE_CLICK_SCRIPT="yabai -m space --focus \$SID 2>/dev/null"

sid=0
for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))
  sketchybar --add space      space.$sid left                               \
             --set space.$sid associated_space=$sid                         \
                              icon=${SPACE_ICONS[i]}                        \
                              icon.padding_left=22                          \
                              icon.padding_right=22                         \
                              label.padding_right=33                        \
                              icon.highlight_color=$WHITE               \
                              background.padding_left=-8                    \
                              background.padding_right=-8                   \
                              background.color=0xff$CBACK                   \
                              background.drawing=on                         \
                              label.font="$FONT:Regular:16.0"               \
                              label.background.height=26                    \
                              label.background.drawing=on                   \
                              label.background.color=$BACKGROUND_2          \
                              label.background.corner_radius=9              \
                              label.drawing=off                             \
                              script="$PLUGIN_DIR/space.sh"                 \
                              click_script="$SPACE_CLICK_SCRIPT"
done

sketchybar   --add item       separator left                          \
             --set separator  icon=                                  \
                              icon.font="$FONT:16.0"                  \
                              background.padding_left=26              \
                              background.padding_right=15             \
                              label.drawing=off                       \
                              associated_display=active               \
                              icon.color=0xff$CFORE
