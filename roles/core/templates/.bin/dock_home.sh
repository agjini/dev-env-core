#!/bin/sh

xrandr --output eDP1 --off

xrandr --output HDMI1 --primary --auto

xrandr --output DP2-2 --auto --right-of HDMI1

