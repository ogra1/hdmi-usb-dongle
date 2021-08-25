#! /bin/sh

# set some defaults
WIDTH="1280"
HEIGHT="720"
FPS="30"
FMT="mjpg"

pid=$$

terminate() {
  pkill -9 -P "$pid"
}

trap terminate 1 2 3 9 15 0

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

find_device () {
	VENDORS="534d" # add more vendor IDs here
	DEV="$(for vendor in $VENDORS; do for file in /sys/bus/usb/devices/*/idVendor; do \
		if grep -q $vendor $file 2>/dev/null; then \
			ls $(echo $file| sed 's/idVendor/*/')/video4linux; \
		fi; \
	done; done | sort | head -1)"
	echo $DEV
	}

[ -n "$DEVICE" ] || DEVICE="/dev/$(find_device)"

# make audio work (poor man's loopback monitor with two piped pacat commands)
if snapctl is-connected audio-record; then
	AUDIODEV="$(pactl list sources|grep Name|grep MACROSILICON|sed 's/^.*: //')"
	pacat -r --device="$AUDIODEV" --latency-msec=1 | pacat -p --latency-msec=1 &
fi

# run mplayer with options from config file
$SNAP/usr/bin/mplayer -ao pulse tv:// \
	-tv driver=v4l2:device=${DEVICE}:width=${WIDTH}:height=${HEIGHT}:fps=${FPS}:outfmt=${FMT} \
	-title "HDMI USB Dongle" >/dev/null 2>&1
