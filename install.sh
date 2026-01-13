###############################################################################
# Build Zenity checklist input (newline safe)
###############################################################################

URL_LIST=""
while IFS='|' read -r NAME URL BROWSER; do
    [ -z "$NAME" ] && continue
    URL_LIST="${URL_LIST}FALSE\n${NAME}\n"
done < "${SOURCE_FILE}"

###############################################################################
# Zenity checklist (newline safe)
###############################################################################

URLS=$(printf "%b" "$URL_LIST" | zenity --list \
    --title="Internet Media Links" \
    --height=600 \
    --width=350 \
    --text="Please choose the links that you would like to add to Game Mode." \
    --column="Select" \
    --column="Service" \
    --checklist)

if [ $? -ne 0 ]; then
    echo "USER: Operation cancelled by the user."
    exit 0
fi

###############################################################################
# Parse Zenity output (newline safe)
###############################################################################

readarray -t arrSelected <<< "${URLS}"

echo "DEBUG: Selected sites: ${arrSelected[*]}"

###############################################################################
# Process each selected site
###############################################################################

for ITEM in "${arrSelected[@]}"; do
    # Trim whitespace
    ITEM="$(echo "$ITEM" | xargs)"

    # Find matching line in index
    NEW_ITEM=$(grep -F "^${ITEM}|" "${SOURCE_FILE}" || true)

    if [ -z "$NEW_ITEM" ]; then
        echo "WARN: Could not find entry for '${ITEM}' in index."
        continue
    fi

    NAME="${NEW_ITEM%%|*}"
    REST="${NEW_ITEM#*|}"
    URL="${REST%%|*}"
    BROWSER="${REST##*|}"

    # Override browser if user selected Brave
    if [ -n "${OVERRIDE_BROWSER}" ]; then
        BROWSER="${OVERRIDE_BROWSER}"
    fi

    echo "DEBUG: Parsed -> NAME='${NAME}' URL='${URL}' BROWSER='${BROWSER}'"

    # Create desktop entry
    DESKTOP_FILE="${APPS_PATH}/${NAME}.desktop"

    if [ ! -e "${DESKTOP_FILE}" ]; then
        echo "INSTALL: Creating launcher for ${NAME}"

        cat > "${DESKTOP_FILE}" <<EOF
[Desktop Entry]
Icon=
Name=${NAME}
Type=Application
Exec=${SCRIPT_COMMAND} ${BROWSER} "${URL}"
EOF

        chmod 0755 "${DESKTOP_FILE}"

        # Ensure browser exists
        flatpak info "${BROWSER}" >/dev/null 2>&1 || {
            echo "INSTALL: Installing missing browser ${BROWSER}"
            sudo flatpak --assumeyes install "${BROWSER}"
            flatpak --user override --filesystem=/run/udev:ro "${BROWSER}"
        }

        echo "INSTALL: Adding ${NAME} to Steam"
        steamos-add-to-steam "${DESKTOP_FILE}"
        sleep 1
    else
        echo "INSTALL: Entry ${NAME} already exists. Skipping."
    fi
done
