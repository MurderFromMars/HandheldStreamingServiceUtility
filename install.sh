#!/bin/bash
# Handheld Streaming Service Utility 

set -e

###############################################
# Config
###############################################

WORK_DIR="$(dirname "$(realpath "$0")")"
OUTPUT_DIR="${WORK_DIR}/output"

# Detect if we're on SteamOS or regular Linux
if command -v steamos-add-to-steam >/dev/null 2>&1; then
    APPS_PATH="${HOME}/Applications"
    IS_STEAMOS=true
else
    APPS_PATH="${HOME}/.local/share/applications"
    IS_STEAMOS=false
fi

SOURCE_FILE="${WORK_DIR}/links.index"

# Remote applist (your repo)
REMOTE_APPLIST_URL="https://raw.githubusercontent.com/MurderFromMars/HandheldStreamingServiceUtility/main/data/links.index"

mkdir -p "${OUTPUT_DIR}" "${APPS_PATH}"

###############################################
# Helper: ensure links.index exists
###############################################
ensure_applist() {
    if [ -f "${SOURCE_FILE}" ]; then
        echo "Using existing applist: ${SOURCE_FILE}"
        return 0
    fi

    echo "Fetching applist from ${REMOTE_APPLIST_URL}..."
    curl -fLo "${SOURCE_FILE}" "${REMOTE_APPLIST_URL}" || {
        echo "ERROR: Failed to download links.index"
        exit 1
    }
}

###############################################
# Helper: ensure Flatpak Chrome is installed
###############################################
ensure_chrome_flatpak() {
    if flatpak info com.google.Chrome >/dev/null 2>&1; then
        echo "Flatpak Google Chrome is already installed."

        # Ensure Chrome has access to ~/Applications (for SteamOS)
        if [ "${IS_STEAMOS}" = true ]; then
            flatpak --user override --filesystem="${HOME}/Applications" com.google.Chrome || true
        fi
        return 0
    fi

    echo "Installing Flatpak Google Chrome..."
    if ! command -v sudo >/dev/null 2>&1; then
        echo "ERROR: sudo not found. Cannot install Flatpak Chrome automatically."
        exit 1
    fi

    sudo flatpak --assumeyes install com.google.Chrome

    # Optional: give browser access to controllers/udev if needed
    flatpak --user override --filesystem=/run/udev:ro com.google.Chrome || true

    # Give Chrome access to ~/Applications if on SteamOS
    if [ "${IS_STEAMOS}" = true ]; then
        flatpak --user override --filesystem="${HOME}/Applications" com.google.Chrome || true
    fi
}

###############################################
# Helper: generate Markdown list of services
###############################################
generate_markdown_links() {
    if [ ! -f "${SOURCE_FILE}" ]; then
        echo "No links.index found for Markdown generation."
        return 0
    fi

    sed -e 's/^/* [/' \
        -e 's/|com.*$//' \
        -e 's/|/](/' \
        -e 's/$/)/' \
        "${SOURCE_FILE}" > "${OUTPUT_DIR}/links.md"

    echo "Markdown link list written to ${OUTPUT_DIR}/links.md"
}

###############################################
# Main installer
###############################################
run_installer() {
    ensure_applist
    ensure_chrome_flatpak

    # Build Zenity checklist from applist
    declare -a allEntries=()
    while read -r LINE; do
        # Skip empty or comment lines
        [ -z "${LINE}" ] && continue
        [[ "${LINE}" =~ ^# ]] && continue

        NAME="${LINE%%|*}"
        allEntries+=("FALSE" "${NAME}")
    done < "${SOURCE_FILE}"

    if [ ${#allEntries[@]} -eq 0 ]; then
        echo "No entries found in links.index."
        exit 1
    fi

    # Let user pick services
    SELECTED=$(zenity --title "Streaming Services" \
        --list \
        --height=600 \
        --width=400 \
        --text="Choose the services you want to add as fullscreen Chrome web apps." \
        --column="Select" \
        --column="Service" \
        --checklist \
        "${allEntries[@]}")

    if [ $? -ne 0 ] || [ -z "${SELECTED}" ]; then
        echo "No services selected or operation cancelled."
        exit 0
    fi

    IFS='|' read -r -a arrSelected <<< "${SELECTED}"

    if [ "${IS_STEAMOS}" = true ]; then
        echo "SteamOS detected - creating web apps for Steam..."
    else
        echo "Creating web app entries for application menu..."
    fi

    for ITEM in "${arrSelected[@]}"; do
        MATCH_LINE=$(grep "^${ITEM}|" "${SOURCE_FILE}" || true)
        if [ -z "${MATCH_LINE}" ]; then
            echo "WARNING: Could not find entry for '${ITEM}' in links.index, skipping."
            continue
        fi

        NAME="${MATCH_LINE%%|*}"
        REST="${MATCH_LINE#*|}"
        URL="${REST%%|*}"
        # Third field (browser ID) is ignored; we force Chrome

        DESKTOP_FILE="${APPS_PATH}/${NAME}.desktop"

        if [ -e "${DESKTOP_FILE}" ]; then
            echo "Skipping existing entry: ${NAME}"
            continue
        fi

        echo "Creating: ${DESKTOP_FILE}"
        cat <<EOF > "${DESKTOP_FILE}"
[Desktop Entry]
Name=${NAME}
Type=Application
Icon=
Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 com.google.Chrome --kiosk --start-fullscreen --force-device-scale-factor=1.25 "${URL}"
EOF

        chmod 0644 "${DESKTOP_FILE}"

        # Add to Steam if on SteamOS
        if [ "${IS_STEAMOS}" = true ]; then
            echo "Adding ${NAME} to Steam..."
            steamos-add-to-steam "${DESKTOP_FILE}" || true
        fi
    done

    generate_markdown_links

    if [ "${IS_STEAMOS}" = true ]; then
        echo "Done. Your web apps should now appear in Steam."
    else
        echo "Done. Your web apps should now appear in your application menu."
        echo "If they don't appear immediately, you may need to log out and back in."
    fi
}

run_installer
