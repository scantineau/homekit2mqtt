#!/bin/bash

cd /root/app

rm -f /var/run/dbus/pid /var/run/avahi-daemon/pid

dbus-daemon --system
avahi-daemon -D

./index.js