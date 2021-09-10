#!/bin/sh

xrandr --output eDP-1 --off

xrandr --output HDMI-0 --off
xrandr --output HDMI-1 --off
xrandr --output HDMI-2 --off

xrandr --output DP-1-1 --primary --auto
xrandr --output DP-1-2 --auto --right-of DP-1-1

