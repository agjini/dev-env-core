#!/bin/bash

isDocked() {
    boltctl list | grep disconnected
    echo $?
}

if [ "$(isDocked)" = "1" ]; then

    echo "docked"
    ~/.screenlayout/dock_home.sh

else

    echo "undocked"
    ~/.screenlayout/laptop.sh

fi;
