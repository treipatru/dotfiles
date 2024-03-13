#!/usr/bin/env bash

# We are assuming that the environment has some exports
# - ROFI_CONFIG: a rasi file containing the desired config
# - ROFI_THEME: a rasi file containing the desired theme

# Get a list of rfkill items, get items and status
RFKILL_ITEMS=$(rfkill |\
    # Remove first line which contains table headers
    tail -n+2 |\
    awk '{
        if ($4 == "blocked")
            status = "";
        else if ($4 == "unblocked")
            status = "";

        # We are basing the functionality of this script
        # on the SOFT blocking of devices. This is in
        # column no. 4.
        print status,$2,$4
    }'
)

# Format list for display
ROFI_ITEMS=$(echo "$RFKILL_ITEMS" | awk '{print $1," "$2}')

# Select an item via rofi
SELECTED_ITEM=$(echo -e "$ROFI_ITEMS" |\
    rofi -dmenu \
        -i \
        -theme "$ROFI_THEME" \
        -config "$ROFI_CONFIG" |\
    awk '{print $2}'
)

# Extract the status of the selected item
# Can only be "blocked"/"unblocked"
SELECTED_ITEM_STATUS=$(echo "$RFKILL_ITEMS" |\
    grep "$SELECTED_ITEM" |\
    awk '{print $3}'
)

# Switch to the other state of the selected item
if [[ "$SELECTED_ITEM_STATUS" = "blocked" ]]; then
    rfkill unblock "$SELECTED_ITEM"
elif [[  "$SELECTED_ITEM_STATUS" = "unblocked" ]]; then
    rfkill block "$SELECTED_ITEM"
fi
