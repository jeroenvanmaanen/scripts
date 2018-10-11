#!/usr/bin/env bash

/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | sed -n -e 's/^ *SSID: //p'