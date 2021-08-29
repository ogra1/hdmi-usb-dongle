#! /usr/bin/env python3

import os
import pystray
import subprocess
from PIL import Image

state = False

def on_clicked(icon, item):
    global state
    state = not item.checked
    do_mute(state)

def get_sink():
    args = ['pactl', 'list', 'sources']
    p = subprocess.Popen(args, stdout=subprocess.PIPE)
    output = p.communicate()[0].decode("utf-8")
    for line in output.split('\n'):
        if 'Name: ' in line:
            if 'MACROSILICON' in line:
                return line.split(':')[1].strip()

def do_mute(state):
    sink = get_sink()
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
