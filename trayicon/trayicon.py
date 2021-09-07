#! /usr/bin/env python3

import os
import pystray
import subprocess
import sys
from PIL import Image

state = False

def on_clicked(icon, item):
    global state
    state = not item.checked
    do_mute(state)

def do_mute(state):
    sink = sys.argv[1]
    args = ['pactl', 'set-source-mute', sink, str(state)]
    p = subprocess.Popen(args)

image = Image.open(os.environ["SNAP"]+"/snap/gui/trayicon.png")
icon = pystray.Icon(name ="HDMI Dongle", icon =image, title ="HDMI Dongle", menu = pystray.Menu(
    pystray.MenuItem(
        'Mute',
        on_clicked,
        checked=lambda item: state))
        )
icon.run()
