# Shell variables
# Generated by 'wal'
wallpaper="None"

# Special
background='#1F1F28'
foreground='#DCD7BA'
cursor='#C8C093'

# Colors
color0='#090618'
color1='#C34043'
color2='#76946A'
color3='#C0A36E'
color4='#7E9CD8'
color5='#957FB8'
color6='#6A9589'
color7='#C8C093'
color8='#727169'
color9='#E82424'
color10='#98BB6C'
color11='#E6C384'
color12='#7FB4CA'
color13='#938AA9'
color14='#7AA89F'
color15='#DCD7BA'

# FZF colors
export FZF_DEFAULT_OPTS="
    $FZF_DEFAULT_OPTS
    --color fg:7,bg:0,hl:1,fg+:232,bg+:1,hl+:255
    --color info:7,prompt:2,spinner:1,pointer:232,marker:1
"

# Fix LS_COLORS being unreadable.
export LS_COLORS="${LS_COLORS}:su=30;41:ow=30;42:st=30;44:"