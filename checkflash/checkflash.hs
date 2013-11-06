#!/bin/bash
#
# Script disables screensaver if flash player is being played in 
# full screen mode and disables it if it's not in full screen
# mode.
# Script checks every n seconds for changes.
#
# For screept to work you need at least awk and xwininfo packages.

# number of seconds script checks for Fullscreen
seconds=30;

# Finds out window id
function getWindowID {
   windowid=$(xwininfo -display $DISPLAY -root -children | grep plugin-container | head -n1 | awk '{print $1}');
   echo $windowid;
}

# Checks if flash is in full screen
function getFullscreen {
    id=$(getWindowID);
    Fullscreen=$(xwininfo -id $id -all | grep Fullscreen);
    echo $Fullscreen;
}

# Disabling screen saver
function disableScreenSaver { 
    xset -dpms;
    xset s off;
}

# Enabling screen saver
function enableScreenSaver { 
    xset +dpms;
    xset s on;
}

# Every n seconds checks if in full screen and accordingly
# to activated enable or disable screen saver
function main {
    activated=0;

    while [ 1 -eq 1 ]; do
        sleep $seconds;
        echo "after sleep";

        if [ "$(getFullscreen)" = "Fullscreen" ]; then
            echo "after first if";
            if [ $activated -eq 0 ]; then 
                disableScreenSaver;
                activated=1;
            fi
        else 
            echo "first else";
            if [ $activated -eq 1 ]; then
            enableScreenSaver;
            activated=0;
            fi
        fi
    done
}

main
