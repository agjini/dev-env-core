#!/bin/sh

xrandr --output eDP1 --off

xrandr --output HDMI-0 --off
xrandr --output HDMI-1 --off
xrandr --output HDMI-2 --off

xrandr --output DP1-1 --primary --auto
xrandr --output DP1-2 --auto --right-of DP1-1

