#!/bin/sh

xrandr --output eDP1 --off

xrandr --output DP1-1 --primary --auto

xrandr --output DP2-2 --auto --right-of DP1-1

