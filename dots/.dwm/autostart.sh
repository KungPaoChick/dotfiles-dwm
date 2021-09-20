#!/bin/env bash

# sets wallpaper using feh
bash $HOME/.dwm/.fehbg

# starts dwmblocks
dwmblocks &

# kill if already running
killall -9 picom xfce4-power-manager dunst

# start compositor and power manager
xfce4-power-manager &
picom --config $HOME/.dwm/picom.conf &

# start polkit
if [[ ! `pidof xfce-polkit` ]]; then
    /usr/lib/xfce-polkit/xfce-polkit &
fi

# start udiskie
udiskie &
