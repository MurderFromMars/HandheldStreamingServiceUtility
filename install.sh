#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

# Handheld Streaming Service Utility - installer

set -e

###############################################################################
# paths and constants
###############################################################################

ROOT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
INDEX_PATH="${ROOT_DIR}/links.index"

LAUNCHER_DIR="${HOME}/Applications"
HELPER_DIR="${HOME}/bin"
HELPER_SCRIPT="${HELPER_DIR}/handheld--browser-open"

INDEX_URL="https://github.com/MurderFromMars/HandheldStreamingServiceUtility/raw/main/data/links.index"
HELPER_URL="https://github.com/MurderFromMars/HandheldStreamingServiceUtility/raw/main/bin/handheld--browser-open"

BROWSER_OVERRIDE=""

###############################################################################
# setup helpers
###############################################################################

create_required_dirs() {
    for dir in "${LAUNCHER_DIR}" "${HELPER_DIR}"; do
        if [ ! -d "${dir}" ]; then
            mkdir -p "${dir}"
            echo "SETUP: Created directory ${dir}."
        fi
    done
}

update_index_file() {
    if [ -f "${INDEX_PATH}" ]; then
        rm -f "${INDEX_PATH}"
        echo "SETUP: Removed existing index ${INDEX_PATH}."
    fi

    echo "SETUP: Downloading index data..."
    curl -fsSL -o "${INDEX_PATH}" "${INDEX_URL}"
}

install_helper_script() {
    echo "SETUP: Downloading browser launcher script..."
    curl -fsSL -o "${HELPER_SCRIPT}" "${HELPER_URL}"
    chmod 0755 "${HELPER_SCRIPT}"
}

###############################################################################
# browser choice
###############################################################################

pick_browser_profile() {
    local answer

    answer="$(
        zenity --list \
            --title="Browser selection" \
            --text="Select which browser you want to use for all streaming shortcuts:" \
            --radiolist \
            --column="Select" --column="Browser" \
            TRUE  "Google Chrome and Microsoft Edge (Best Compatibility)" \
            FALSE "Brave Browser (Best Privacy)"
    )"

    if [ $? -ne 0 ]; then
        echo "USER: Operation cancelled during browser selection."
        exit 0
    fi

    case "${answer}" in
        "Brave Browser (Best Privacy)"|"Brave Browser")
            echo "USER: Brave Browser chosen. Overriding all per-entry browser settings."
            BROWSER_OVERRIDE="com.brave.Browser"
            ;;
        *)
            echo "USER: Using default browser assignments (Chrome and Edge)."
            BROWSER_OVERRIDE=""
            ;;
    esac
}

###############################################################################
# site selection
###############################################################################

build_site_list() {
    local line name
    SELECTION_ENTRIES=()

    while IFS= read -r line; do
        [ -z "${line}" ] && continue
        name="${line%%|*}"
        echo "URLS: Found site ${name}."
        SELECTION_ENTRIES+=("FALSE" "${name}")
    done < "${INDEX_PATH}"

    echo "URLS: All available sites: [${SELECTION_ENTRIES[*]}]"
}

prompt_for_sites() {
    local output

    output="$(
        zenity --title="Internet Media Links" \
            --list \
            --height=600 \
            --width=350 \
            --text="Select the services you want to add to Game Mode." \
            --column="Select" \
            --column="Service" \
            --checklist \
            "${SELECTION_ENTRIES[@]}"
    )"

    if [ $? -ne 0 ]; then
        echo "USER: Operation cancelled at site selection."
        exit 0
    fi

    IFS='|' read -r -a CHOSEN_SITES <<< "${output}"
    echo "URLS: Selected sites: ${CHOSEN_SITES[*]}"
}

###############################################################################
# launcher creation
###############################################################################

ensure_browser_flatpak() {
    local app_id="$1"

    echo "INSTALL: Checking Flatpak dependency for ${app_id}..."
    if ! flatpak info "${app_id}" >/dev/null 2>&1; then
        echo "INSTALL: ${app_id} not found. Installing..."
        sudo flatpak --assumeyes install "${app_id}"
        flatpak --user override --filesystem=/run/udev:ro "${app_id}"
    fi
}

create_desktop_entry() {
    local name="$1"
    local url="$2"
    local browser="$3"
    local desktop="${LAUNCHER_DIR}/${name}.desktop"

    if [ -e "${desktop}" ]; then
        echo "INSTALL: Entry ${name} already exists. Skipping."
        return
    fi

    echo "INSTALL: Adding entry ${name} -> ${url}."
    cat > "${desktop}" <<EOF
[Desktop Entry]
Icon=
Name=${name}
Type=Application
Exec=${HELPER_SCRIPT} ${browser} "${url}"
EOF

    chmod 0755 "${desktop}"

    ensure_browser_flatpak "${browser}"

    echo "INSTALL: Adding ${name} to Steam."
    steamos-add-to-steam "${desktop}"
    sleep 1
}

process_selected_sites() {
    local item line name rest url browser

    for item in "${CHOSEN_SITES[@]}"; do
        line="$(grep "^${item}|" "${INDEX_PATH}" || true)"
        [ -z "${line}" ] && continue

        name="${line%%|*}"
        rest="${line#*|}"
        url="${rest%%|*}"
        browser="${rest##*|}"

        if [ -n "${BROWSER_OVERRIDE}" ]; then
            browser="${BROWSER_OVERRIDE}"
        fi

        create_desktop_entry "${name}" "${url}" "${browser}"
    done
}

###############################################################################
# main
###############################################################################

create_required_dirs
update_index_file
install_helper_script
pick_browser_profile
build_site_list
prompt_for_sites
process_selected_sites

echo "DONE: All selected streaming services have been configured."
