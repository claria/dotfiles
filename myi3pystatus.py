# -*- coding: utf-8 -*-

import subprocess

from i3pystatus import Status

status = Status(standalone=True)

# Displays clock like this:
# Tue 30 Jul 11:59:46 PM KW31
#                          ^-- calendar week
status.register("clock",
    format="%a %-d %b %X KW%V",)

# Shows the average load of the last minute and the last 5 minutes
# (the default value for format is used)
status.register("load",
        critical_limit=4.,
        critical_color="#FFFFFF")

# Shows your CPU temperature, if you have a Intel CPU
# status.register("temp",
#    format="{temp:.0f}°C",)

# The battery monitor has many formatting options, see README for details

# This would look like this, when discharging (or charging)
# ↓14.22W 56.15% [77.81%] 2h:41m
# And like this if full:
# =14.22W 100.0% [91.21%]
#
# This would also display a desktop notification (via dbus) if the percentage
# goes below 5 percent while discharging. The block will also color RED.
status.register("battery",
    format="{status} {percentage:.2f}%",
    alert=False,
    color='#ffffff',
    full_color='#ffffff',
    charging_color='#ffffff',
    alert_percentage=5,
    status={
        "DIS": "↓",
        "CHR": "↑",
        "FULL": "=",
    },)

# Shows the address and up/down state of eth0. If it is up the address is shown in
# green (the default value of color_up) and the CIDR-address is shown
# (i.e. 10.10.10.42/24).
# If it's down just the interface name (eth0) will be displayed in red
# (defaults of format_down and color_down)
#
# Note: the network module requires PyPI package netifaces-py3
status.register("network",
    interface="enp0s25",
    format_up="{v4cidr}",
    color_down="#FFFFFF",
    color_up="#FFFFFF")

# Has all the options of the normal network and adds some wireless specific things
# like quality and network names.
#
# Note: requires both netifaces-py3 and basiciw
status.register("network",
    interface="wlp3s0",
    format_up="{essid}",
    color_down="#FFFFFF",
    color_up="#FFFFFF")

# Shows disk usage of /
# Format:
# 42/128G [86G]
status.register("dpms")

status.register("disk",
    path="/home/",
    color='#FFFFFF',
    critical_color='#FFFFFF',
    critical_limit=0,
    format="⌂:{percentage_used}%",)

status.register("disk",
    path="/",
    color='#FFFFFF',
    critical_color='#FFFFFF',
    critical_limit=0,
    format="√:{percentage_used}%",)

# Shows pulseaudio default sink volume
#
# Note: requires libpulseaudio from PyPI
status.register("pulseaudio",
        format="♪:{volume}%",)

status.run()
