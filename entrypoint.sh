#!/bin/bash

# Set strict error handling
if [[ -z "${GITHUB_WORKSPACE}" ]]; then
    GITHUB_WORKSPACE="/workspace"
fi

# Input validation function
validate_input() {
    local name="$1"
    local value="$2"
    local type="$3"
    
    if [[ -z "$value" ]]; then
        echo "FATAL: Input $name is required but not provided."
        exit 1
    fi
    
    case "$type" in
        "numeric")
            if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                echo "FATAL: Input $name must be a positive integer, got: $value"
                exit 1
            fi
            ;;
        "path")
            if [[ ! -d "$value" ]]; then
                echo "FATAL: Input $name path does not exist: $value"
                exit 1
            fi
            # Prevent path traversal
            local abs_path="$(realpath "$value")"
            local workspace_root="$(realpath "${GITHUB_WORKSPACE:-/workspace}")"
            if [[ "$abs_path" != "$workspace_root"* ]]; then
                echo "FATAL: Input $name path must be within the workspace: $value"
                exit 1
            fi
            ;;
        "string")
            # Basic string validation - prevent empty and potentially dangerous characters
            if [[ "$value" =~ [^[:print:]] ]]; then
                echo "FATAL: Input $name contains non-printable characters"
                exit 1
            fi
            ;;
        "changenote")
            if [[ "$value" =~ [^[:print:]] ]]; then
                echo "FATAL: Input changenote contains non-printable characters"
                exit 1
            fi
            if [[ ${#value} -gt 1000 ]]; then
                echo "FATAL: Input changenote too long (max 1000 characters): ${#value}"
                exit 1
            fi
            ;;
    esac
}

# Set shell options for strict error handling
set -euo pipefail

if [[ -z "${STEAM_USERNAME}" ]]; then
    echo "FATAL: Environment variable STEAM_USERNAME is required but not provided."
    exit 1
fi

if [[ -z "${STEAM_PASSWORD}" ]]; then
    echo "FATAL: Environment variable STEAM_PASSWORD is required but not provided."
    exit 1
fi

# Validate required inputs
validate_input "appid" "${INPUT_APPID}" "numeric"
validate_input "itemid" "${INPUT_ITEMID}" "numeric"
validate_input "path" "${INPUT_PATH}" "path"
validate_input "changenote" "${INPUT_CHANGENOTE}" "changenote"

cat << EOF > /home/steam/workshop.vdf
"workshopitem"
{
  "appid" "${INPUT_APPID}"
  "contentfolder" "${GITHUB_WORKSPACE}/${INPUT_PATH}"
  "changenote" "${INPUT_CHANGENOTE}"
  "publishedfileid" "${INPUT_ITEMID}"
}
EOF

cat '/home/steam/workshop.vdf'

# Define the command function
run_steamcmd() {
    if [[ -z "${STEAM_2FASEED}" ]]; then
        /home/steam/steamcmd/steamcmd.sh +@ShutdownOnFailedCommand 1 +login "${STEAM_USERNAME}" "${STEAM_PASSWORD}" +workshop_build_item /home/steam/workshop.vdf +quit
    else
        export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
        STEAM_2FACODE=$(/home/steam/steam-totp "${STEAM_2FASEED}")

        if [[ $? -ne 0 ]]; then
            return 1
        fi

        /home/steam/steamcmd/steamcmd.sh +@ShutdownOnFailedCommand 1 +login "${STEAM_USERNAME}" "${STEAM_PASSWORD}" "${STEAM_2FACODE}" +workshop_build_item /home/steam/workshop.vdf +quit
    fi
}

# Attempt loop
ATTEMPTS_CURRENT=0
ATTEMPTS_MAX=3
IS_SUCCESSFUL=0

while [[ ${ATTEMPTS_CURRENT} -lt ${ATTEMPTS_MAX} ]]; do
    echo "Attempt $((ATTEMPTS_CURRENT+1)) of ${ATTEMPTS_MAX}..."
    run_steamcmd

    if [[ $? -eq 0 ]]; then
        IS_SUCCESSFUL=1
        break
    fi

    ATTEMPTS_CURRENT=$((ATTEMPTS_CURRENT+1))
    echo "Attempt ${ATTEMPTS_CURRENT} failed. Retrying..."
    sleep 2
done

if [[ ${IS_SUCCESSFUL} -eq 1 ]]; then
  exit 0
fi

echo "All ${ATTEMPTS_MAX} attempts failed."
echo 'Showing stderr.txt:'
cat /home/steam/Steam/logs/stderr.txt
echo
echo 'Showing workshop_log.txt:'
cat /home/steam/Steam/logs/workshop_log.txt
exit 2
