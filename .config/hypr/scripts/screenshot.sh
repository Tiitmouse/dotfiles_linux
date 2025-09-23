#!/bin/bash
#  ____                               _           _
# / ___|  ___ _ __ ___  ___ _ __  ___| |__   ___ | |_
# \___ \ / __| '__/ _ \/ _ \ '_ \/ __| '_ \ / _ \| __|
#  ___) | (__| | |  __/  __/ | | \__ \ | | | (_) | |_
# |____/ \___|_|  \___|\___|_| |_|___/_| |_|\___/ \__|
#
# Based on https://github.com/hyprwm/contrib/blob/main/grimblast/screenshot.sh
# -----------------------------------------------------

# Screenshots will be stored in $HOME by default.
# The screenshot will be moved into the screenshot directory

# Add this to ~/.config/user-dirs.dirs to save screenshots in a custom folder:
# XDG_SCREENSHOTS_DIR="$HOME/Screenshots"

prompt='Screenshot'
mesg="DIR: ~/Screenshots"

# Screenshot Filename
source ~/.config/ml4w/settings/screenshot-filename.sh # Ensure this sets the NAME variable with full path if possible

# Screenshot Folder
source ~/.config/ml4w/settings/screenshot-folder.sh

# Screenshot Editor
export GRIMBLAST_EDITOR="$(cat ~/.config/ml4w/settings/screenshot-editor.sh)"


# --- Argument Parsing ---
DIRECT_MODE_TYPE=""
DIRECT_MODE_ACTION="save" # Default action if called directly

if [ -n "$1" ]; then
    case "$1" in
        full|screen)
            DIRECT_MODE_TYPE="screen"
            ;;
        select|area)
            DIRECT_MODE_TYPE="area"
            ;;
        window|active)
            DIRECT_MODE_TYPE="active" # Use grimblast's 'active' type for focused window
            ;;
        menu|interactive)
            # Force interactive mode
            DIRECT_MODE_TYPE=""
            ;;
        *)
            echo "Usage: $0 [full|select|window|menu] [save|copy|copysave|edit]"
            # Default to interactive if unknown argument
            DIRECT_MODE_TYPE=""
           ;;
    esac
    # Allow specifying action as second arg, e.g., screenshot.sh full copy
    if [ -n "$2" ]; then
         case "$2" in
            copy|save|copysave|edit)
                DIRECT_MODE_ACTION="$2"
                ;;
         esac
    fi
fi
# --- End Argument Parsing ---


# Options (for Rofi menus)
option_1="Immediate"
option_2="Delayed"

option_capture_1="Capture Everything"
option_capture_2="Capture Active Display"
option_capture_3="Capture Selection"

option_time_1="5s"
option_time_2="10s"
option_time_3="20s"
option_time_4="30s"
option_time_5="60s"

list_col='1'
list_row='2'

copy='Copy'
save='Save'
copy_save='Copy & Save'
edit='Edit'

# Rofi CMD (Functions for interactive mode)
rofi_cmd() { rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 2 -width 30 -p "Take screenshot"; }
run_rofi() { echo -e "$option_1\n$option_2" | rofi_cmd; }
timer_cmd() { rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 5 -width 30 -p "Choose timer"; }
timer_exit() { echo -e "$option_time_1\n$option_time_2\n$option_time_3\n$option_time_4\n$option_time_5" | timer_cmd; }
type_screenshot_cmd() { rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 3 -width 30 -p "Type of screenshot"; }
type_screenshot_exit() { echo -e "$option_capture_1\n$option_capture_2\n$option_capture_3" | type_screenshot_cmd; }
copy_save_editor_cmd() { rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 4 -width 30 -p "How to save"; }
copy_save_editor_exit() { echo -e "$copy\n$save\n$copy_save\n$edit" | copy_save_editor_cmd; }

# Timer logic (for interactive mode)
timer() {
    # ... (timer function as you had it) ...
    if [[ $countdown -gt 10 ]]; then
        notify-send -t 1000 "Taking screenshot in ${countdown} seconds"
        countdown_less_10=$((countdown - 10))
        sleep $countdown_less_10
        countdown=10
    fi
    while [[ $countdown -ne 0 ]]; do
        notify-send -t 1000 "Taking screenshot in ${countdown} seconds"
        countdown=$((countdown - 1))
        sleep 1
    done
}


# takescreenshot function (modified to handle direct mode)
takescreenshot() {
    # Use pre-defined MODE and ACTION if set by args, otherwise use rofi selections from global vars
    local type_to_use=${DIRECT_MODE_TYPE:-$option_type_screenshot}
    local action_to_use=${DIRECT_MODE_ACTION:-$option_chosen}

    # Make sure required variables are set
    if [ -z "$type_to_use" ] || [ -z "$action_to_use" ]; then
         notify-send -u critical "Screenshot Error: Type or action not determined."
         echo "Error: Screenshot type or action not determined."
         exit 1
    fi

    # Ensure the target directory exists if saving
    if [[ "$action_to_use" == "save" || "$action_to_use" == "copysave" || "$action_to_use" == "edit" ]]; then
        # Assumes NAME variable from screenshot-filename.sh includes the full desired path
         mkdir -p "$(dirname "$NAME")"
         # Check if directory creation failed (e.g., permissions)
         if [ $? -ne 0 ]; then
            notify-send -u critical "Screenshot Error: Cannot create directory $(dirname "$NAME")"
            exit 1
         fi
    fi

    # Slight delay before capture
    sleep 0.3

    # Execute grimblast
    grimblast --notify "$action_to_use" "$type_to_use" "$NAME" # Pass the generated filename/path

    # Note: The original script's file moving logic might be redundant
    # if grimblast saves directly to the path specified in $NAME.
    # If grimblast *always* saves to $HOME first, uncomment and adapt the move logic below.
    # Check if the file was actually saved (relevant for 'save'/'copysave'/'edit')
    # if [[ "$action_to_use" == "save" || "$action_to_use" == "copysave" || "$action_to_use" == "edit" ]]; then
    #    if [ -f "$HOME/$NAME" ]; then # Check if it landed in HOME
    #        if [ -d "$screenshot_folder" ]; then
    #            mv "$HOME/$NAME" "$screenshot_folder/" # Move it
    #        fi
    #    # else, assume grimblast saved it to the correct path in $NAME already
    #    fi
    # fi
}

# takescreenshot_timer function (for interactive delayed mode)
takescreenshot_timer() {
    sleep 0.3 # Short delay before timer starts
    timer
    takescreenshot # Call the main screenshot function after delay
}

# Confirm and execute functions (for interactive mode)
timer_run() {
    selected_timer="$(timer_exit)"
    if [[ "$selected_timer" == "$option_time_1" ]]; then countdown=5; ${1};
    elif [[ "$selected_timer" == "$option_time_2" ]]; then countdown=10; ${1};
    elif [[ "$selected_timer" == "$option_time_3" ]]; then countdown=20; ${1};
    elif [[ "$selected_timer" == "$option_time_4" ]]; then countdown=30; ${1};
    elif [[ "$selected_timer" == "$option_time_5" ]]; then countdown=60; ${1};
    else exit; fi
}
type_screenshot_run() {
    selected_type_screenshot="$(type_screenshot_exit)"
    if [[ "$selected_type_screenshot" == "$option_capture_1" ]]; then option_type_screenshot=screen; ${1};
    elif [[ "$selected_type_screenshot" == "$option_capture_2" ]]; then option_type_screenshot=output; ${1};
    elif [[ "$selected_type_screenshot" == "$option_capture_3" ]]; then option_type_screenshot=area; ${1};
    else exit; fi
}
copy_save_editor_run() {
    selected_chosen="$(copy_save_editor_exit)"
    if [[ "$selected_chosen" == "$copy" ]]; then option_chosen=copy; ${1};
    elif [[ "$selected_chosen" == "$save" ]]; then option_chosen=save; ${1};
    elif [[ "$selected_chosen" == "$copy_save" ]]; then option_chosen=copysave; ${1};
    elif [[ "$selected_chosen" == "$edit" ]]; then option_chosen=edit; ${1};
    else exit; fi
}

# Execute Command (for interactive mode)
run_cmd() {
    if [[ "$1" == '--opt1' ]]; then
        type_screenshot_run # Ask type
        copy_save_editor_run "takescreenshot" # Ask action & take shot
    elif [[ "$1" == '--opt2' ]]; then
        timer_run "type_screenshot_run 'copy_save_editor_run \"takescreenshot_timer\"'" # Ask timer -> type -> action & take shot
    fi
}


# --- Main Execution Logic ---
if [ -n "$DIRECT_MODE_TYPE" ]; then
    # Direct execution mode (argument passed)
    takescreenshot # Call directly with variables set from args
else
    # Interactive mode (no valid argument passed or 'menu' argument)
    chosen="$(run_rofi)"
    case ${chosen} in
        $option_1)
            run_cmd --opt1
            ;;
        $option_2)
            run_cmd --opt2
            ;;
    esac
fi