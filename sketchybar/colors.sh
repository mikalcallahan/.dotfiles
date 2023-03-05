#!/usr/bin/env sh

source ~/.cache/wal/colors.sh # pywal scheme

COLOR0=$(echo $color0 | sed 's/#//')
COLOR1=$(echo $color1 | sed 's/#//')
COLOR2=$(echo $color2 | sed 's/#//')
COLOR3=$(echo $color3 | sed 's/#//')
COLOR4=$(echo $color4 | sed 's/#//')
COLOR5=$(echo $color5 | sed 's/#//')
COLOR6=$(echo $color6 | sed 's/#//')
COLOR7=$(echo $color7 | sed 's/#//')
COLOR8=$(echo $color8 | sed 's/#//')

export CBACK=$(echo $background | sed 's/#//')
export CFORE=$(echo $foreground | sed 's/#//')
export CCURSOR=$(echo $cursor | sed 's/#//')

export CNORM=0xff$COLOR1
export CBLACK=0xff$COLOR0
export CRED=0xff$COLOR1
export CGREEN=0xff$COLOR2
export CYELLOW=0xff$COLOR3
export CBLUE=0xff$COLOR4
export CMAGENTA=0xff$COLOR5
export CCYAN=0xff$COLOR6
export CWHITE=0xff$COLOR7
export CBRIGHT=0xff$COLOR8

export CACTV=$COLOR5
export CBACK_OFFSET=$COLOR2
export CINSE=$CFORE
export CINVISIBLE=0x00555555

# Color Palette
# export BLACK=0xff14181d
# export WHITE=0xffc7c7c7
export BLACK=0xff$CBACK
export WHITE=$CWHITE
#export WHITE=0xff$CFORE
# export RED=0xffa64431
export RED=0xff$CACTV
# export RED=0xff$CBACK
# export GREEN=0xff57bf37
export GREEN=0xff$CGREEN
export BLUE=0xff2d42c0
export YELLOW=0xffc6c43f
export ORANGE=0xfff5a97f
export MAGENTA=0xffb148b8
# export MAGENTA=0xff$CACTV
export GREY=0xff939ab7
export TRANSPARENT=0x00000000

# General bar colors
# export BAR_COLOR=0xcc24273a
export BAR_COLOR=0xff$CBACK
export ICON_COLOR=0xff$CACTV # Color of all icons
export LABEL_COLOR=$WHITE # Color of all labels
# export BACKGROUND_1=0xff3c3e4f
export BACKGROUND_1=0xff$CBACK_OFFSET
export BACKGROUND_2=0xff494d64

export POPUP_BACKGROUND_COLOR=$BLACK
export POPUP_BORDER_COLOR=$WHITE

export SHADOW_COLOR=$BLACK
