#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Scripts for volume controls for audio and mic 

iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

notify_timeout=1000
notify_info=1
notify_color=0 # for default color
notify_font_size="fontsize:18"

# Get Volume
get_volume() {
    volume=$(pamixer --get-volume)
    if [[ "$volume" -eq "0" ]]; then
        echo "Muted"
    else
        echo "$volume %"
    fi
}

# Get icons
get_icon() {
    current=$(get_volume)
    if [[ "$current" == "Muted" ]]; then
        echo "$iDIR/volume-mute.png"
    elif [[ "${current%\%}" -le 30 ]]; then
        echo "$iDIR/volume-low.png"
    elif [[ "${current%\%}" -le 60 ]]; then
        echo "$iDIR/volume-mid.png"
    else
        echo "$iDIR/volume-high.png"
    fi
}

# Notify
notify_user() {
    if [[ "$(get_volume)" == "Muted" ]]; then
		hyprctl notify $notify_info $notify_timeout $notify_color "$notify_font_size Volume Muted"
    else
		hyprctl notify $notify_info $notify_timeout $notify_color "$notify_font_size Volume Level: $(get_volume)"
        "$sDIR/Sounds.sh" --volume
    fi
}

# Increase Volume
inc_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        toggle_mute
    else
        pamixer -i 5 --allow-boost --set-limit 150 && notify_user
    fi
}

# Decrease Volume
dec_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        toggle_mute
    else
        pamixer -d 5 && notify_user
    fi
}

# Toggle Mute
toggle_mute() {
	if [ "$(pamixer --get-mute)" == "false" ]; then
		pamixer -m && hyprctl notify $notify_info $notify_timeout $notify_color "$notify_font_size Volume Muted"
	elif [ "$(pamixer --get-mute)" == "true" ]; then
		pamixer -u && hyprctl notify $notify_info $notify_timeout $notify_color "$notify_font_size Volume Level: $(get_volume)"
	fi
}

# Toggle Mic
toggle_mic() {
	if [ "$(pamixer --default-source --get-mute)" == "false" ]; then
		pamixer --default-source -m && hyprctl notify $notify_info $notify_timeout $notify_color "$notify_font_size Microphone Muted"
	elif [ "$(pamixer --default-source --get-mute)" == "true" ]; then
		pamixer --default-source -u && hyprctl notify $notify_info $notify_timeout $notify_color "$notify_font_size Microphone Unmuted"
	fi
}
# Get Mic Icon
get_mic_icon() {
    current=$(pamixer --default-source --get-volume)
    if [[ "$current" -eq "0" ]]; then
        echo "$iDIR/microphone-mute.png"
    else
        echo "$iDIR/microphone.png"
    fi
}

# Get Microphone Volume
get_mic_volume() {
    volume=$(pamixer --default-source --get-volume)
    if [[ "$volume" -eq "0" ]]; then
        echo "Muted"
    else
        echo "$volume %"
    fi
}

# Notify for Microphone
notify_mic_user() {
    volume=$(get_mic_volume)
    icon=$(get_mic_icon)
    # notify-send -e -h int:value:"$volume" -h "string:x-canonical-private-synchronous:volume_notif" -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$icon"  " Mic Level:" " $volume"
	hyprctl notify $notify_info $notify_timeout $notify_color "$notify_font_size Mic Level: $volume"
	"$sDIR/Sounds.sh" --mic-volume
}

# Increase MIC Volume
inc_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle_mic
    else
        pamixer --default-source -i 5 && notify_mic_user
    fi
}

# Decrease MIC Volume
dec_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle-mic
    else
        pamixer --default-source -d 5 && notify_mic_user
    fi
}

# Execute accordingly
if [[ "$1" == "--get" ]]; then
	get_volume
elif [[ "$1" == "--inc" ]]; then
	inc_volume
elif [[ "$1" == "--dec" ]]; then
	dec_volume
elif [[ "$1" == "--toggle" ]]; then
	toggle_mute
elif [[ "$1" == "--toggle-mic" ]]; then
	toggle_mic
elif [[ "$1" == "--get-icon" ]]; then
	get_icon
elif [[ "$1" == "--get-mic-icon" ]]; then
	get_mic_icon
elif [[ "$1" == "--mic-inc" ]]; then
	inc_mic_volume
elif [[ "$1" == "--mic-dec" ]]; then
	dec_mic_volume
else
	get_volume
fi
