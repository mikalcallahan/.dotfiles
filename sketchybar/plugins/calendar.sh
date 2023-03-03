#!/usr/bin/env sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# sketchybar --set $NAME label="$(date '+%a %d. %b %H:%M')"
sketchybar --set $NAME icon="$(LANG=fr_CA date '+%a %d. %b')" label="$(date '+%H:%M')"
