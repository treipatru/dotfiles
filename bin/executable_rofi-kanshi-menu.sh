#!/usr/bin/env bash

# We are assuming that the environment has some exports
# - ROFI_CONFIG: a rasi file containing the desired config
# - ROFI_THEME: a rasi file containing the desired theme

# Define the file containing the data
KANSHI_CFG=~/.config/kanshi/config

# Create an empty string to store profile names
KANSHI_PROFILES=""

# Read the file line by line
while IFS= read -r line; do
    # Check if the line contains 'profile'
    if [[ $line == profile* ]]; then
        # Extract the profile name
        profile_name=$(echo "$line" | awk '{print $2}')
        # Append the profile name to the list
        KANSHI_PROFILES+="$profile_name"$'\n'
    fi
done < "$KANSHI_CFG"

# Remove trailing newline
KANSHI_PROFILES=$(echo "$KANSHI_PROFILES" | sed '/^$/d')

# Display the list of profiles using Rofi or dmenu
SELECTED_PROFILE=$(echo "$KANSHI_PROFILES" |\
    rofi -dmenu -theme $ROFI_THEME -config $ROFI_CONFIG -mesg "Select a screens profile")

# Echo the selected profile
echo "Selected profile: $SELECTED_PROFILE"
kanshictl switch "$SELECTED_PROFILE"
