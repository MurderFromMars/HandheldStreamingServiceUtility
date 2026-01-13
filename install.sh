#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

# Handheld Streaming Service Utility (rewritten version)

WORK_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
SOURCE_FILE="${WORK_DIR}/links.index"
APPS_PATH="${HOME}/Applications"
SCRIPT_PATH="${HOME}/bin"
SCRIPT_COMMAND="${SCRIPT_PATH}/steamfork-browser-open"

###############################################################################
# Ensure required directories exist
###############################################################################

for DIR in "$APPS_PATH" "$SCRIPT_PATH"; do
    if [ ! -d "$DIR" ]; then
        mkdir -p "$DIR"
        echo "SETUP: Created directory $DIR."
    fi
done

###############################################################################
# Download index + helper script
###############################################################################

[ -f "$SOURCE_FILE" ] && rm -f "$SOURCE_FILE"

echo "SETUP: Fetching source data..."
curl -fsSL -o "$SOURCE_FILE" \
    "https://github.com/SteamFork/SetupStreamingServices/raw/main/data/links.index"

echo "SETUP: Fetching browser script..."
curl -fsSL -o "$SCRIPT_COMMAND" \
    "https://github.com/SteamFork/SetupStreamingServices/raw/main/bin/steamfork-browser-open"

chmod 0755 "$SCRIPT_COMMAND"

###############################################################################
# Browser selection
###############################################################################

BROWSER_CHOICE=$(
    zenity --list \
        --title="Browser Selection" \
        --text="Please select the browser you would like to use for all URLs:" \
        --radiolist \
        --column="Select" --column="Browser" \
        TRUE  "Google Chrome and Microsoft Edge (Best Compatibility)" \
        FALSE "Brave Browser (Best Privacy)"
)

if [ $? -ne 0 ]; then
    echo "USER: Operation cancelled by the user."
    exit 0
fi

if [[ "$BROWSER_CHOICE" == "Brave Browser"* ]]; then
    OVERRIDE_BROWSER="com.brave.Browser"
else
    OVERRIDE_BROWSER=""
fi

###############################################################################
# Build Zenity checklist input (newline-safe)
###############################################################################

CHECKLIST=""
while IFS='|' read -r NAME URL BROWSER; do
    [ -z "$NAME" ] && continue
    CHECKLIST="${CHECKLIST}FALSE\n${NAME}\n"
done < "$SOURCE_FILE"

###############################################################################
# Zenity checklist
###############################################################################

SELECTIONS=$(
    printf "%b" "$CHECKLIST" |
        zenity --list \
            --title="Internet Media Links" \
            --height=600 \
            --width=350 \
            --text="Please choose the links that you would like to add to Game Mode." \
            --column="Select" \
            --column="Service" \
            --checklist
)

if [ $? -ne 0 ]; then
    echo "USER: Operation cancelled by the user."
    exit 0
fi

###############################################################################
# Parse Zenity output (newline-safe)
###############################################################################

readarray -t SELECTED <<< "$SELECTIONS"

###############################################################################
# Process each selected service
###############################################################################

for ITEM in "${SELECTED[@]}"; do
    ITEM="$(echo "$ITEM" | xargs)"  # trim whitespace

    MATCH=$(grep -F "^${ITEM}|" "$SOURCE_FILE" || true)
    if [ -z "$MATCH" ]; then
        echo "WARN: Could not find entry for '$ITEM' in index."
        continue
    fi

    NAME="${MATCH%%|*}"
    REST="${MATCH#*|}"
    URL="${REST%%|*}"
    BROWSER="${REST##*|}"

    # Override browser if user selected Brave
    [ -n "$OVERRIDE_BROWSER" ] && BROWSER="$OVERRIDE_BROWSER"

    DESKTOP_FILE="${APPS_PATH}/${NAME}.desktop"

    if [ ! -f "$DESKTOP_FILE" ]; then
        echo "INSTALL: Creating launcher for $NAME"

        cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Icon=
Name=${NAME}
Type=Application
Exec=${SCRIPT_COMMAND} ${BROWSER} "${URL}"
EOF

        chmod 0755 "$DESKTOP_FILE"

        # Ensure browser Flatpak exists
        if ! flatpak info "$BROWSER" >/dev/null 2>&1; then
            echo "INSTALL: Installing missing browser $BROWSER"
            sudo flatpak --assumeyes install "$BROWSER"
            flatpak --user override --filesystem=/run/udev:ro "$BROWSER"
        fi

        echo "INSTALL: Adding $NAME to Steam"
        steamos-add-to-steam "$DESKTOP_FILE"
        sleep 1
    else
        echo "INSTALL: Entry $NAME already exists. Skipping."
    fi
done

echo "DONE: All selected services have been added."
