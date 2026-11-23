#!/bin/bash

# Updates an existing Steam Workshop item with the content of a local folder.
#
# The script runs directly on the runner. See scripts/install-steamcmd.sh for
# why SteamCMD is no longer executed inside a container.

set -euo pipefail

GITHUB_WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
STEAMCMD_ROOT="${STEAMCMD_ROOT:-${RUNNER_TEMP:-/tmp}/steamcmd}"
STEAMCMD_HOME="${STEAMCMD_HOME:-${STEAMCMD_ROOT}/home}"
STEAMCMD_SH="${STEAMCMD_ROOT}/install/steamcmd.sh"
STEAM_TOTP_BIN="${STEAMCMD_ROOT}/steam-totp"
LOG_DIR="${STEAMCMD_HOME}/Steam/logs"
WORKSHOP_VDF="${STEAMCMD_ROOT}/workshop.vdf"

ATTEMPTS_MAX=3
POST_UPLOAD_COOLDOWN_SECONDS=30

# Sanitize sensitive values from output
sanitize_output() {
    local output="$1"

    if [[ -n "${STEAM_PASSWORD:-}" ]]; then
        output="${output//${STEAM_PASSWORD}/***REDACTED***}"
    fi

    if [[ -n "${STEAM_2FACODE:-}" ]]; then
        output="${output//${STEAM_2FACODE}/***REDACTED***}"
    fi

    if [[ -n "${STEAM_2FASEED:-}" ]]; then
        output="${output//${STEAM_2FASEED}/***REDACTED***}"
    fi

    echo "$output"
}

# Log sanitized command for debugging
log_sanitized_cmd() {
    local cmd="$1"
    echo "DEBUG: $(sanitize_output "$cmd")"
}

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
            local abs_path
            local workspace_root
            abs_path="$(realpath "$value")"
            workspace_root="$(realpath "$GITHUB_WORKSPACE")"
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
        *)
            echo "FATAL: Unknown validation type for input $name."
            exit 1
            ;;
    esac
}

if [[ -z "${STEAM_USERNAME:-}" ]]; then
    echo "FATAL: Environment variable STEAM_USERNAME is required but not provided."
    exit 1
fi

if [[ -z "${STEAM_PASSWORD:-}" ]]; then
    echo "FATAL: Environment variable STEAM_PASSWORD is required but not provided."
    exit 1
fi

if [[ ! -x "${STEAMCMD_SH}" ]]; then
    echo "FATAL: SteamCMD was not found at ${STEAMCMD_SH}. Run scripts/install-steamcmd.sh first."
    exit 1
fi

# Validate required inputs
validate_input "appid" "${INPUT_APPID:-}" "numeric"
validate_input "itemid" "${INPUT_ITEMID:-}" "numeric"
validate_input "path" "${GITHUB_WORKSPACE}/${INPUT_PATH:-}" "path"
validate_input "changenote" "${INPUT_CHANGENOTE:-}" "changenote"

mkdir -p "${STEAMCMD_ROOT}"

cat << EOF > "${WORKSHOP_VDF}"
"workshopitem"
{
  "appid" "${INPUT_APPID}"
  "contentfolder" "${GITHUB_WORKSPACE}/${INPUT_PATH}"
  "changenote" "${INPUT_CHANGENOTE}"
  "publishedfileid" "${INPUT_ITEMID}"
}
EOF

cat "${WORKSHOP_VDF}"

# Define the command function
run_steamcmd() {
    local -a steamcmd_args=(
        "${STEAMCMD_SH}"
        +@ShutdownOnFailedCommand 1
        +login "${STEAM_USERNAME}"
        "${STEAM_PASSWORD}"
    )

    if [[ -z "${STEAM_2FASEED:-}" ]]; then
        steamcmd_args+=(+workshop_build_item "${WORKSHOP_VDF}" +quit)
    else
        export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

        if ! STEAM_2FACODE=$("${STEAM_TOTP_BIN}" "${STEAM_2FASEED}"); then
            echo "FATAL: Failed to generate the TOTP code" >&2
            return 1
        fi

        # Validate TOTP code format (alphanumeric, 5-6 characters for Steam)
        if ! [[ "${STEAM_2FACODE}" =~ ^[A-Za-z0-9]{5,6}$ ]]; then
            echo "FATAL: Generated TOTP code has an invalid format." >&2
            return 1
        fi

        echo "DEBUG: TOTP code validation passed"
        steamcmd_args+=("${STEAM_2FACODE}" +workshop_build_item "${WORKSHOP_VDF}" +quit)
    fi

    log_sanitized_cmd "${steamcmd_args[*]}"
    HOME="${STEAMCMD_HOME}" "${steamcmd_args[@]}"
}

# Attempt loop. The command is tested directly so that a failed attempt is
# retried rather than aborting the script through errexit.
ATTEMPTS_CURRENT=0
IS_SUCCESSFUL=0

while [[ ${ATTEMPTS_CURRENT} -lt ${ATTEMPTS_MAX} ]]; do
    ATTEMPTS_CURRENT=$((ATTEMPTS_CURRENT+1))
    echo "Attempt ${ATTEMPTS_CURRENT} of ${ATTEMPTS_MAX}..."

    if run_steamcmd; then
        IS_SUCCESSFUL=1
        break
    fi

    echo "Attempt ${ATTEMPTS_CURRENT} failed."

    if [[ ${ATTEMPTS_CURRENT} -lt ${ATTEMPTS_MAX} ]]; then
        echo "Retrying..."
        sleep 2
    fi
done

if [[ ${IS_SUCCESSFUL} -eq 1 ]]; then
    echo "Upload successful. Waiting ${POST_UPLOAD_COOLDOWN_SECONDS} seconds before continuing..."
    sleep "${POST_UPLOAD_COOLDOWN_SECONDS}"
    exit 0
fi

echo "All ${ATTEMPTS_MAX} attempts failed."

for log_name in stderr.txt workshop_log.txt; do
    log_path="${LOG_DIR}/${log_name}"
    echo "Showing ${log_name}:"

    if [[ -f "${log_path}" ]]; then
        sanitize_output "$(cat "${log_path}")"
    else
        echo "(not found at ${log_path})"
    fi

    echo
done

exit 2
