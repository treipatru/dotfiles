#!/usr/bin/env bash

# We are assuming that the environment has some exports
# - ROFI_CONFIG: a rasi file containing the desired config
# - ROFI_THEME: a rasi file containing the desired theme

NET_INTERFACE="wlp1s0"

# Verify if wifi is up and return early if not
NET_INTERFACE_AVAILABLE=$(nmcli device show "$NET_INTERFACE" |\
    grep STATE |\
    grep unavailable
)
if [[ -n "$NET_INTERFACE_AVAILABLE" ]]; then
    notify-send -u normal -t 3000 "Network" "WiFi interface not available"
    exit 0
fi

# Connections known to nmcli
SAVED_CONNECTIONS=$(nmcli -g NAME connection)

# Send notification to start
notify-send -u normal -t 5000 "Network" "Getting list of available WiFi networks..."

# Get a list of available wifi connections and morph it into a nice-looking list
SSID_LIST=$(nmcli --fields "SSID,RATE,SIGNAL,SECURITY,IN-USE" device wifi list |\
    # Remove first line which contains table headers
    tail -n+2 |\
    # Remove lines starting with --
    grep -v '^--' |\
    awk 'BEGIN {
        security_keys[0] = "WPA";
        security_keys[1] = "WPA1";
        security_keys[2] = "WPA2";
        security_keys[3] = "WPA3";
        security_keys[4] = "802.1x";
    }
    {
        # Network security is "unlocked" by default
        # Check if any of the known types of security are present
        security = "";
        for (i in security_keys) {
            if ($5 == security_keys[i] || $6 == security_keys[i]) {
                security = "";
                break;
            }
        }

        # Convert the network speed to MegaBytes
        speed= sprintf("%.0f", $2 / 8);

        # Set a signal icon
        if ($4 < 30)
            signal = "󰢼";
        else if ($4 < 70)
            signal = "󰢽";
        else
           signal = "󰢾";

        print security,signal,speed,$1
    }' |\
    awk ' {
        ssid = $4
        speed = $3

        # Some networks advertise multiple bandwidths with the same SSID
        # Look for duplicates and keep the one with higher available bandwitdh
        if (ssid in seen && speed > max[ssid]){
            max[ssid] = speed
            lines[ssid] = $0
        } else if (!(ssid in seen)) {
            seen[ssid] = 1
            max[ssid] = speed
            lines[ssid] = $0
        }
    }
    END {
        for (key in lines)
            print lines[key]
    }'
)
echo "$SSID_LIST"
# Get SSID of current connection
ROFI_MESG=$(nmcli con show | grep $NET_INTERFACE | awk '{
    if ($1 == "") {
        print "Select a network"
    } else {
        print$1" connected | Search for a new SSID..."
    }
}')

# Use rofi to select wifi network
SELECTED_NETWORK=$(echo -e "$SSID_LIST" |\
    rofi -dmenu -i \
        -theme  "$ROFI_THEME" \
        -config "$ROFI_CONFIG" \
        -mesg   "$ROFI_MESG" \
        -no-custom
)

# Get SSID from selection
NETWORK_SSID=$(echo "$SELECTED_NETWORK" | awk '{print $4}')

if [ "$NETWORK_SSID" = "" ]; then
	exit
else
  	MSG_SUCCESS="Connected to \"$NETWORK_SSID\"."


    # If the selected network is known just connect to it
	if [[ $(echo "$SAVED_CONNECTIONS" | grep -w "$NETWORK_SSID") = "$NETWORK_SSID" ]]; then
		nmcli connection up id "$NETWORK_SSID" | grep "successfully" && notify-send -t 3000 "Network" "$MSG_SUCCESS"
        exit 0
    fi

    # If the selected network is new and it requires password
    if [[ "$SELECTED_NETWORK" =~ "" ]]; then
        WIFI_PASS=$(rofi -dmenu -theme $ROFI_THEME -config $ROFI_CONFIG -mesg "Password for $($NETWORK_SSID)" )
    fi
    nmcli device wifi connect "$NETWORK_SSID" password "$WIFI_PASS" | grep "successfully" && notify-send -t 3000 "Network" "$MSG_SUCCESS"
fi
