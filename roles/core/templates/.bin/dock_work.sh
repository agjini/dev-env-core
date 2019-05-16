#!/bin/sh

xrandr --output eDP1 --auto --primary

xrandr --output DP1-1 --auto --right-of eDP1

xrandr --output DP1-2 --off
