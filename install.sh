#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

# Handheld Streaming Service Utility
# Reworked launcher registration script for Steam Deck–like environments.

###############################################################################
# Configuration
###############################################################################

BASE_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
INDEX_FILE="${BASE_DIR}/links.index"

LAUNCHERS_DIR="${HOME}/Applications"
HELPER_DIR="${HOME}/bin"
HELPER_SCRIPT="${HELPER_DIR}/steamfork-browser-open"

INDEX_URL="https://github.com/SteamFork/SetupStreamingServices/raw/main/data/links.index"
HELPER_URL="https://github.com/SteamFork/SetupStreamingServices/raw/main/bin/steamfork-browser-open"

###############################################################################
# Helpers
###############################################################################

ensure_directory() {
    local path="$1"
    if [ ! -d "$path" ]; then
        mkdir -p "$path"
        echo "SETUP: Created directory $path."
    fi
}

fetch_file() {
    local url="$1"
    local target="$2"

    echo "SETUP: Downloading $url -> $target"
    curl -fsSL -o "$target" "$url"
}

pick_browser() {
    local choice

    choice=$(
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

    case "$choice" in
        "Brave Browser"*"Best Privacy"*)
            echo "USER: Brave Browser selected. Overriding all browser selections."
            echo "com.brave.Browser"
            ;;
        *)
            echo "USER: Default browsers (Google Chrome and Microsoft Edge) selected."
            echo ""
            ;;
    esac
}

build_service_checklist() {
    # Reads INDEX_FILE and emits a flat list suitable for zenity --checklist
    local -a entries=()
    while IFS= read -r line; do
        # Skip empty lines
        [ -z "$line" ] && continue

        local name="${line%%|*}"
        echo "URLS: Found site $name."
        entries+=("FALSE" "$name")
    done < "$INDEX_FILE"

    echo "${entries[@]}"
}

prompt_for_services() {
    local -a checklist_items
    IFS=' ' read -r -a checklist_items <<< "$(build_service_checklist)"

    echo "URLS: All available sites: [${checklist_items[*]}]"

    local selection
    selection=$(
        zenity --title "Internet Media Links" \
            --list \
            --height=600 \
            --width=350 \
            --text="Please choose the links that you would like to add to Game Mode." \
            --column="Select" \
            --column="URL" \
            --checklist \
            "${checklist_items[@]}"
    )

    if [ $? -ne 0 ]; then
        echo "USER: Operation cancelled by the user."
        exit 0
    fi

    echo "$selection"
}

parse_selection_list() {
    # Takes the raw zenity output and splits it into an array via |
    local raw="$1"
    local -n out_ref="$2"

    IFS='|' read -r -a out_ref <<< "$raw"
}

lookup_service_line() {
    local name="$1"
    grep "^${name}|" "$INDEX_FILE" || true
}

create_launcher() {
    local name="$1"
    local url="$2"
    local browser_id="$3"

    local desktop_file="${LAUNCHERS_DIR}/${name}.desktop"

    if [ -e "$desktop_file" ]; then
        echo "INSTALL: Entry $name already exists. Skipping."
        return
    fi

    echo "INSTALL: Adding entry $name -> $url."
    cat <<EOF > "$desktop_file"
[Desktop Entry]
Icon=
Name=${name}
Type=Application
Exec=${HELPER_SCRIPT} ${browser_id} "${url}"
EOF

    chmod 0755 "$desktop_file"

    echo "INSTALL: Checking for ${browser_id} Flatpak dependency..."
    if ! flatpak info "${browser_id}" >/dev/null 2>&1; then
        echo "INSTALL: Installing ${browser_id} Flatpak..."
        sudo flatpak --assumeyes install "${browser_id}"
        flatpak --user override --filesystem=/run/udev:ro "${browser_id}"
    fi

    echo "INSTALL: Adding ${name} to Steam."
    steamos-add-to-steam "$desktop_file"
    sleep 1
}

###############################################################################
# Main flow
###############################################################################

# Ensure necessary directories
ensure_directory "$LAUNCHERS_DIR"
ensure_directory "$HELPER_DIR"

# Refresh index file
if [ -e "$INDEX_FILE" ]; then
    rm -f "$INDEX_FILE"
    echo "SETUP: Removed existing source file $INDEX_FILE."
fi

fetch_file "$INDEX_URL" "$INDEX_FILE"
fetch_file "$HELPER_URL" "$HELPER_SCRIPT"
chmod 0755 "$HELPER_SCRIPT"

# Let the user choose a browser override
BROWSER_OVERRIDE="$(pick_browser)"

# Let the user choose which services to install
RAW_SELECTIONS="$(prompt_for_services)"

declare -a SELECTED_SERVICES=()
parse_selection_list "$RAW_SELECTIONS" SELECTED_SERVICES
echo "URLS: Selected sites: ${SELECTED_SERVICES[*]}"

# Process each selected service
for service_name in "${SELECTED_SERVICES[@]}"; do
    service_line="$(lookup_service_line "$service_name")"
    [ -z "$service_line" ] && {
        echo "WARN: Could not find entry for $service_name in index."
        continue
    }

    entry_name="${service_line%%|*}"
    remainder="${service_line#*|}"
    entry_url="${remainder%%|*}"
    entry_browser="${remainder##*|}"

    # Apply user-selected override if present
    if [ -n "$BROWSER_OVERRIDE" ]; then
        entry_browser="$BROWSER_OVERRIDE"
    fi

    create_launcher "$entry_name" "$entry_url" "$entry_browser"
done
