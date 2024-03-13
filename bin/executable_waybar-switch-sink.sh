#!/bin/bash

ALL_SINKS=$(pactl list sinks | awk '/Sink #/{sink=$2} /Name: /{name=$2} /Description: /{desc=$0} /State: /{state=$2} {if (sink && name && desc && state) {gsub(/^[^:]+: /, "", desc); print "Sink#: "sink", Name: "name", Description: "desc", State: "state; sink=""; name=""; desc=""; state=""}}')
EXCLUDED_SINKS=("alsa_output.pci-0000_c1_00.1.hdmi-stereo-extra2")

# Filter out excluded sinks
for excluded_sink in "${EXCLUDED_SINKS[@]}"; do
    ALL_SINKS=$(echo "$ALL_SINKS" | grep -v "$excluded_sink")
done

# Filter out sinks with state "RUNNING"
ALL_SINKS=$(echo "$ALL_SINKS" | grep -v "State: RUNNING")

# Early return if no other sinks are available
if [[ $(echo "$ALL_SINKS" | wc -l) -eq 0 ]]; then
    exit
fi

# If only one is available set next sink to it directly
if [[ $(echo "$ALL_SINKS" | wc -l) -eq 1 ]]; then
    NEXT_SINK_ID=$(echo "$ALL_SINKS" | awk -F'Sink#: ' 'NR==1 {split($2, arr, ","); sub(/^#/, "", arr[1]); print arr[1]}')
fi

# If multiple sinks do additional checks
if [[ $(echo "$ALL_SINKS" | wc -l) -gt 1 ]]; then
    # Prefer bluetooth sinks - check if `bluez` is in the name
    if echo "$ALL_SINKS" | grep -q "bluez"; then
        NEXT_SINK_ID=$(echo "$ALL_SINKS" | grep 'bluez' | head -n 1 | awk -F'Sink#: ' 'NR==1 {split($2, arr, ","); sub(/^#/, "", arr[1]); print arr[1]}')
    else
        # Otherwise return first in list
        NEXT_SINK_ID=$(echo "$ALL_SINKS" | awk -F'Sink#: ' 'NR==1 {split($2, arr, ","); sub(/^#/, "", arr[1]); print arr[1]}')
    fi
fi

# Warn user of change
DESCRIPTION=$(echo "$ALL_SINKS" | grep "$NEXT_SINK_ID" | sed 's/^.*Description: //;s/,.*$//')
notify-send -u normal -t 3000 "Audio Output" "Switching to $DESCRIPTION"

# Switch to next sink
pactl set-default-sink $NEXT_SINK_ID
