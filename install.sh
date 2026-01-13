#!/usr/bin/env bash

set -euo pipefail

readonly INSTALL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly INDEX_URL="https://github.com/SteamFork/SetupStreamingServices/raw/main/data/links.index"
readonly LAUNCHER_URL="https://github.com/SteamFork/SetupStreamingServices/raw/main/bin/steamfork-browser-open"

# Directory structure
readonly USER_APPS="${HOME}/Applications"
readonly USER_SCRIPTS="${HOME}/bin"
readonly LAUNCHER_SCRIPT="${USER_SCRIPTS}/steamfork-browser-open"
readonly INDEX_FILE="${INSTALL_ROOT}/links.index"

# Browser constants
readonly CHROME_ID="com.google.Chrome"
readonly EDGE_ID="com.microsoft.Edge"
readonly BRAVE_ID="com.brave.Browser"

# Ensure required directories exist
setup_directories() {
    local dir
    for dir in "${USER_APPS}" "${USER_SCRIPTS}"; do
        [[ -d "${dir}" ]] && continue
        mkdir -p "${dir}"
        echo "Created: ${dir}"
    done
}

# Download required files
fetch_resources() {
    echo "Downloading service index..."
    [[ -f "${INDEX_FILE}" ]] && rm -f "${INDEX_FILE}"
    curl -fsSL -o "${INDEX_FILE}" "${INDEX_URL}"
    
    echo "Downloading launcher executable..."
    curl -fsSL -o "${LAUNCHER_SCRIPT}" "${LAUNCHER_URL}"
    chmod +x "${LAUNCHER_SCRIPT}"
}

# Prompt user for browser preference
select_browser() {
    local choice
    choice=$(zenity --list \
        --title="Choose Your Browser" \
        --text="Select which browser to use for web applications:" \
        --radiolist \
        --column="" --column="Browser Option" \
        TRUE "Chrome/Edge (Recommended for compatibility)" \
        FALSE "Brave (Privacy-focused alternative)") || {
        echo "Browser selection cancelled"
        exit 0
    }
    
    if [[ "${choice}" == *"Brave"* ]]; then
        echo "${BRAVE_ID}"
    else
        echo ""
    fi
}

# Build service selection array from index
build_service_list() {
    local -n result_array=$1
    local line service_name
    
    while IFS='|' read -r service_name _; do
        [[ -z "${service_name}" ]] && continue
        result_array+=("FALSE" "${service_name}")
        echo "Found: ${service_name}"
    done < "${INDEX_FILE}"
}

# Present service selection dialog
choose_services() {
    local -a service_options=()
    build_service_list service_options
    
    zenity --list \
        --title="Web Application Installer" \
        --text="Select applications to add to Gaming Mode:" \
        --checklist \
        --height=600 \
        --width=350 \
        --column="Add" \
        --column="Application" \
        "${service_options[@]}" || {
        echo "Service selection cancelled"
        exit 0
    }
}

# Parse index entry for a given service name
parse_service_entry() {
    local service_name="$1"
    local index_line
    
    index_line=$(grep -F "${service_name}|" "${INDEX_FILE}" | head -n1)
    echo "${index_line}"
}

# Install flatpak if not present
ensure_flatpak() {
    local flatpak_id="$1"
    
    if flatpak info "${flatpak_id}" &>/dev/null; then
        return 0
    fi
    
    echo "Installing: ${flatpak_id}"
    sudo flatpak --assumeyes install "${flatpak_id}"
    flatpak --user override --filesystem=/run/udev:ro "${flatpak_id}"
}

# Generate desktop entry file
create_desktop_entry() {
    local app_name="$1"
    local browser_id="$2"
    local target_url="$3"
    local desktop_file="${USER_APPS}/${app_name}.desktop"
    
    [[ -f "${desktop_file}" ]] && {
        echo "Skipping existing entry: ${app_name}"
        return 1
    }
    
    cat > "${desktop_file}" << DESKTOP_EOF
[Desktop Entry]
Icon=
Name=${app_name}
Type=Application
Exec=${LAUNCHER_SCRIPT} ${browser_id} "${target_url}"
DESKTOP_EOF
    
    chmod +x "${desktop_file}"
    echo "Created launcher: ${app_name}"
    return 0
}

# Register with Steam
add_to_steam() {
    local desktop_file="$1"
    
    echo "Registering with Steam: $(basename "${desktop_file}")"
    steamos-add-to-steam "${desktop_file}"
    sleep 1
}

# Main installation loop
install_services() {
    local browser_override="$1"
    local selected_services="$2"
    local -a services_array
    local service entry app_name target_url browser_id
    
    IFS='|' read -ra services_array <<< "${selected_services}"
    
    for service in "${services_array[@]}"; do
        entry=$(parse_service_entry "${service}")
        [[ -z "${entry}" ]] && continue
        
        IFS='|' read -r app_name target_url browser_id <<< "${entry}"
        
        # Apply browser override if specified
        [[ -n "${browser_override}" ]] && browser_id="${browser_override}"
        
        ensure_flatpak "${browser_id}"
        
        if create_desktop_entry "${app_name}" "${browser_id}" "${target_url}"; then
            add_to_steam "${USER_APPS}/${app_name}.desktop"
        fi
    done
}

# Entry point
main() {
    setup_directories
    fetch_resources
    
    local browser_preference selected
    browser_preference=$(select_browser)
    echo "Browser mode: ${browser_preference:-default}"
    
    selected=$(choose_services)
    [[ -z "${selected}" ]] && {
        echo "No services selected"
        exit 0
    }
    
    echo "Installing selected services..."
    install_services "${browser_preference}" "${selected}"
    
    echo "Installation complete!"
}

main "$@"
