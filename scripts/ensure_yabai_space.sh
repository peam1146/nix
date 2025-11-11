#!/bin/bash

DISPLAY_SPACES=([1]=2 [2]=6)

# The main logic equivalent to the Lua function ensure_yabai_space()
ensure_yabai_space() {
    # 1. Query all displays and get the JSON output
    local displays_json=$(yabai -m query --displays)

    # Check if yabai command succeeded and returned data
    if [ $? -ne 0 ] || [ -z "$displays_json" ]; then
        echo "Error: Failed to query yabai displays or received empty output." >&2
        return 1
    fi

    # 2. Loop through each display object using jq
    # The '.[]' iterates over the array elements.
    # The 'r' flag ensures raw string output for the print statements.
    # The 'c' flag compacts the output onto a single line.
    echo "$displays_json" | jq -r -c '.[]' | while IFS= read -r display; do
        # Extract necessary fields for the current display using jq
        local display_id=$(echo "$display" | jq -r '.id')uw
        local display_index=$(echo "$display" | jq -r '.index')
        local has_focus=$(echo "$display" | jq -r '."has-focus"')
        # Count the number of spaces in the 'spaces' array
        local spaces_count=$(echo "$display" | jq '.spaces | length')

        # Get the desired limit for the current display index
        local limit_spaces=${DISPLAY_SPACES[$display_index]}

        # If no limit is defined for this display index, skip it
        if [ -z "$limit_spaces" ]; then
            echo "Warning: No space limit defined for display index $display_index. Skipping." >&2
            continue
        fi

        # 3. Focus the display if it doesn't have focus (Optional step from Lua)
        if [ "$has_focus" = "false" ]; then
             yabai -m display --focus $display_id
            # Note: The Lua script focuses every time it's not focused, which can interrupt flow.
        fi

        # 4. Check if we need to create or destroy spaces
        local diff

        if [ "$spaces_count" -lt "$limit_spaces" ]; then
            # Need to create spaces
            diff=$((limit_spaces - spaces_count))
            echo "Display $display_index (ID: $display_id) has $spaces_count spaces, needs $limit_spaces. Creating $diff spaces."

            for ((i = 1; i <= diff; i++)); do
                # The Lua logic had a strange combination: create a space, then move it to the display.
                # 'yabai -m space --create' creates a space on the focused display.
                # 'yabai -m space --display N' moves the *current* space to display N.
                # The following is a guess at the intended combined action: create a new space and assign it to the target display ID.
                # If yabai allows 'yabai -m space $SPACE_ID --display $DISPLAY_ID', you might need to find the ID of the new space first.
                # Assuming the original Lua meant: create a new space on the focused display, then move the space that yabai
                # automatically focuses after creation to the target display.
                echo "yabai -m space --create && yabai -m space --display $display_id" # Print what would be executed
                yabai -m space --create && yabai -m space --display $display_id
            done

        elif [ "$spaces_count" -gt "$limit_spaces" ]; then
            # Need to destroy spaces
            diff=$((spaces_count - limit_spaces))
            echo "Display $display_index (ID: $display_id) has $spaces_count spaces, needs $limit_spaces. Destroying $diff spaces."

            # The Lua script destroyed space by index `limit_spaces`, which is the first space
            # that should be destroyed (e.g., if limit is 2 and there are 4, it destroys space 3, 3, 3).
            # We destroy starting from the index immediately after the limit.
            local space_to_destroy=$((limit_spaces + 1))

            for ((i = 1; i <= diff; i++)); do
                echo "yabai -m space --destroy $space_to_destroy" # Print what would be executed
                yabai -m space --destroy $space_to_destroy
            done
        else
            echo "Display $display_index (ID: $display_id) has $spaces_count spaces, which is the desired limit. No changes."
        fi

    done
}

# Execute the main function
ensure_yabai_space
