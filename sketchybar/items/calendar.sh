#!/usr/bin/env sh

sketchybar --add item     calendar right                    \
           --set calendar icon.font="$FONT:0xff$CFORE:12.0" \
                          icon.padding_right=0              \
                          label.width=50                    \
                          label.align=right                 \
                          background.padding_left=10        \
                          update_freq=15                    \
                          script="$PLUGIN_DIR/calendar.sh"  \
#                          click_script="$PLUGIN_DIR/zen.sh"
