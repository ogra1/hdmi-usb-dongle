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

VENDORS="534d eba4" # add more vendor IDs here

if snapctl is-connected hardware-observe; then
  # find audio and video devices by vendor id
  for vendor in $VENDORS; do
    VIDEODEV="$(for file in /sys/bus/usb/devices/*/idVendor; do \
        if grep -q $vendor $file 2>/dev/null; then \
          ls $(echo $file| sed 's/idVendor/*/')/video4linux; \
        fi; \
      done | sort | head -1)"
    AUDIODEV="$(LC_ALL=C pactl list sources | \
      sed -n '/^.*Name:.*$/p;/^.*device.vendor.id.*$/p' | \
      grep -B1 $vendor | head -1 | sed 's/^.*Name: //')"
    # stop at the first device found
    [ -n "$VIDEODEV" ] && break
  done
else
  echo "Please connect the hardware-observe snap plug to make device detection possible"
  exit 1
fi

# allow user to override the video device
[ -n "$DEVICE" ] || DEVICE="/dev/${VIDEODEV}"

# show a fancy tray icon with menu
PYTHONPATH=$SNAP/lib/python3.8/site-packages:$SNAP/gnome-platform/usr/lib/python3.8/site-packages $SNAP/usr/bin/trayicon &

if snapctl is-connected audio-record; then
    # make audio work (poor man's loopback monitor with two piped pacat commands)
	if [ -n "$AUDIODEV" ]; then
	  pacat -r --device="$AUDIODEV" --latency-msec=1 | pacat -p --latency-msec=1 &
	else
      echo "No matching audio device found, moving on without sound !!"
    fi
else
	echo "Please connect the audio-record snap plug to get audio support"
fi

if snapctl is-connected camera; then
  # run mplayer with options from config file and detection
  $SNAP/usr/bin/mplayer -ao pulse tv:// \
    -tv driver=v4l2:device=${DEVICE}:width=${WIDTH}:height=${HEIGHT}:fps=${FPS}:outfmt=${FMT} \
    -title "HDMI USB Dongle" >/dev/null 2>&1
else
  echo "Please connect the camera snap plug to get access to the video device"
  exit 1
fi
