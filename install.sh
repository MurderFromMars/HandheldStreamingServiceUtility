#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Handheld Streaming Service Utility Installer

set -e

WORK_DIR="$(dirname "$(realpath "$0")")"
DATA_DIR="${WORK_DIR}/data"
BIN_DIR="${WORK_DIR}/bin"
OUTPUT_DIR="${WORK_DIR}/output"

APPS_PATH="${HOME}/Applications"
SCRIPT_PATH="${HOME}/bin"
SCRIPT_COMMAND="${SCRIPT_PATH}/handheld-browser-open"
SOURCE_FILE="${WORK_DIR}/links.index"

mkdir -p "${DATA_DIR}" "${BIN_DIR}" "${OUTPUT_DIR}"

###############################################
# Convert links.index to Markdown
###############################################
generate_markdown_links() {
    echo "STEP: Generating Markdown link list..."

    if [ ! -f "${SOURCE_FILE}" ]; then
        echo "ERROR: links.index not found at ${SOURCE_FILE}"
        return 1
    fi

    sed -e 's/^/* [/' \
        -e 's/|com.*$//' \
        -e 's/|/](/' \
        -e 's/$/)/' \
        "${SOURCE_FILE}" > "${OUTPUT_DIR}/links.md"

    echo "OUTPUT: Markdown links saved to ${OUTPUT_DIR}/links.md"
}

###############################################
# Browser launcher (embedded)
###############################################
browser_open() {
    local BROWSER="$1"
    local URL="$2"

    if [ -z "${BROWSER}" ]; then
        BROWSER="com.google.Chrome"
    fi

    flatpak info "${BROWSER}" >/dev/null 2>&1
    if (( $? > 0 )); then
        case ${BROWSER} in
            com.google.Chrome) BROWSER="Google Chrome" ;;
            com.microsoft.Edge) BROWSER="Microsoft Edge" ;;
        esac
        zenity --info --text="Please switch to desktop mode and install ${BROWSER} from the Discover Software Center."
        exit 1
    fi

    unset LD_PRELOAD

    /usr/bin/flatpak run \
        --arch=x86_64 \
        --branch=stable \
        --file-forwarding \
        "${BROWSER}" \
        @@u \
        @@ \
        --window-size="1024,640" \
        --force-device-scale-factor="1.25" \
        --device-scale-factor="1.25" \
        --kiosk \
        "${URL}"
}

###############################################
# Main Installer
###############################################
run_installer() {
    echo "STEP: Preparing directories..."

    for DIR in "${APPS_PATH}" "${SCRIPT_PATH}"; do
        if [ ! -d "${DIR}" ]; then
            mkdir -p "${DIR}"
            echo "SETUP: Created directory ${DIR}."
        fi
    done

    if [ -e "${SOURCE_FILE}" ]; then
        rm "${SOURCE_FILE}"
        echo "SETUP: Removed existing source file ${SOURCE_FILE}."
    fi

    echo "STEP: Fetching source data..."
    curl -Lo "${SOURCE_FILE}" \
        "https://raw.githubusercontent.com/MurderFromMars/HandheldStreamingServiceUtility/main/data/links.index"

    echo "STEP: Fetching browser launcher..."
    curl -Lo "${SCRIPT_COMMAND}" \
        "https://raw.githubusercontent.com/MurderFromMars/HandheldStreamingServiceUtility/main/bin/handheld-browser-open"
    chmod 0755 "${SCRIPT_COMMAND}"

    BROWSER_CHOICE=$(zenity --list \
        --title="Browser Selection" \
        --text="Select the browser you want to use for all URLs:" \
        --radiolist \
        --column="Select" --column="Browser" \
        TRUE "Google Chrome and Microsoft Edge (Best Compatibility)" \
        FALSE "Brave Browser (Best Privacy)")

    if [ $? -ne 0 ]; then
        echo "USER: Operation cancelled."
        exit 0
    fi

    if [ "${BROWSER_CHOICE}" = "Brave Browser" ]; then
        OVERRIDE_BROWSER="com.brave.Browser"
        echo "USER: Brave Browser selected."
    else
        OVERRIDE_BROWSER=""
        echo "USER: Default browsers selected."
    fi

    declare -a allURLs=()
    while read -r SITES; do
        SITE="${SITES%%|*}"
        allURLs+=("FALSE" "${SITE}")
    done < "${SOURCE_FILE}"

    URLS=$(zenity --title "Streaming Services" \
        --list \
        --height=600 \
        --width=350 \
        --text="Choose the services you want to add to Game Mode." \
        --column="Select" \
        --column="URL" \
        --checklist \
        "${allURLs[@]}")

    if [ $? -ne 0 ]; then
        echo "USER: Operation cancelled."
        exit 0
    fi

    IFS='|' read -r -a arrSelected <<< "${URLS}"

    echo "STEP: Installing selected entries..."

    for ITEM in "${arrSelected[@]}"; do
        NEW_ITEM=$(grep "^${ITEM}|" "${SOURCE_FILE}")
        NAME="${NEW_ITEM%%|*}"
        NEW_ITEM="${NEW_ITEM#*|}"
        BROWSER="${NEW_ITEM##*|}"
        URL="${NEW_ITEM%%|*}"

        if [ -n "${OVERRIDE_BROWSER}" ]; then
            BROWSER="${OVERRIDE_BROWSER}"
        fi

        DESKTOP_FILE="${APPS_PATH}/${NAME}.desktop"

        if [ ! -e "${DESKTOP_FILE}" ]; then
            echo "INSTALL: Adding entry ${NAME} -> ${URL}"

            cat <<EOF > "${DESKTOP_FILE}"
[Desktop Entry]
Icon=
Name=${NAME}
Type=Application
Exec=${SCRIPT_COMMAND} ${BROWSER} "${URL}"
EOF

            chmod 0755 "${DESKTOP_FILE}"

            echo "INSTALL: Checking for ${BROWSER} Flatpak..."
            flatpak info "${BROWSER}" >/dev/null 2>&1 || {
                echo "INSTALL: Installing ${BROWSER}..."
                sudo flatpak --assumeyes install "${BROWSER}"
                flatpak --user override --filesystem=/run/udev:ro "${BROWSER}"
            }

            echo "INSTALL: Adding ${NAME} to Steam..."
            steamos-add-to-steam "${DESKTOP_FILE}"
            sleep 1
        else
            echo "INSTALL: Entry ${NAME} already exists. Skipping."
        fi
    done

    echo "STEP: Generating Markdown link list..."
    generate_markdown_links

    echo "INSTALLATION COMPLETE."
}

###############################################
# MAIN EXECUTION
###############################################
run_installer
