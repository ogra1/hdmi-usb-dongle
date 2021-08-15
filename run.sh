#! /bin/sh

# set some defaults
DEVICE="/dev/video2"
WIDTH="1280"
HEIGHT="720"
FPS="30"
FMT="mjpg"

# source existing config or ...
if [ -e "$SNAP_USER_DATA/config" ]; then
	. $SNAP_USER_DATA/config
else
    # ... put a fresh config in place
	cat << EOF >$SNAP_USER_DATA/config
# DEVICE="/dev/video2"
# WIDTH="1280"
# HEIGHT="720"
# FPS="30"
# FMT="mjpg"
EOF
fi

# run mplayer with options from config file
$SNAP/usr/bin/mplayer -ao pulse tv:// \
	-tv driver=v4l2:device=${DEVICE}:width=${WIDTH}:height=${HEIGHT}:fps=${FPS}:outfmt=${FMT} \
	-title "HDMI USB Dongle" >/dev/null 2>&1
