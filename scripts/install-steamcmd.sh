#!/bin/bash

# Installs Valve's official SteamCMD distribution natively on the runner.
#
# SteamCMD used to run inside a Docker container. Docker 29.4.2, shipped with
# GitHub's Ubuntu 26.04 runner image, denies socketcall(2) in its default
# seccomp profile. SteamCMD's client is a 32-bit i386 binary, and i386 glibc
# performs socket operations through socketcall(2), so the client cannot
# resolve names or reach Steam at all. It then reports
# "Steamcmd needs to be online to update" and never recovers.
#
# Running SteamCMD directly on the runner avoids the container and its seccomp
# profile entirely.

set -euo pipefail

STEAMCMD_ROOT="${STEAMCMD_ROOT:-${RUNNER_TEMP:-/tmp}/steamcmd}"
STEAMCMD_INSTALL_DIR="${STEAMCMD_ROOT}/install"
STEAMCMD_HOME="${STEAMCMD_HOME:-${STEAMCMD_ROOT}/home}"
STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
STEAM_TOTP_URL="https://github.com/hmlendea/steam-totp/releases/download/v1.0.1/steam-totp_1.0.1_linux-x64"
STEAM_TOTP_BIN="${STEAMCMD_ROOT}/steam-totp"
BOOTSTRAP_ATTEMPTS_MAX=3

download() {
    local url="$1"
    local destination="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${url}" -o "${destination}"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "${url}" -O "${destination}"
    else
        echo "FATAL: Neither curl nor wget is available to download ${url}." >&2
        return 1
    fi
}

# The SteamCMD client is a 32-bit binary, so the host needs a 32-bit loader and
# runtime libraries. Hosted runners provide them; self-hosted runners may not.
ensure_32bit_runtime() {
    if [[ -e /lib/ld-linux.so.2 || -e /lib32/ld-linux.so.2 || -e /usr/lib32/ld-linux.so.2 ]]; then
        echo "32-bit runtime already available."
        return 0
    fi

    local -a privilege=()
    if [[ ${EUID} -ne 0 ]]; then
        privilege+=(sudo)
    fi

    if command -v apt-get >/dev/null 2>&1; then
        echo "Installing lib32gcc-s1 for the 32-bit SteamCMD client..."
        "${privilege[@]}" apt-get update -qq
        "${privilege[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends lib32gcc-s1
    elif command -v dnf >/dev/null 2>&1; then
        echo "Installing glibc.i686 for the 32-bit SteamCMD client..."
        "${privilege[@]}" dnf install -y glibc.i686
    else
        echo "FATAL: No 32-bit loader found and no supported package manager is available." >&2
        echo "Install the 32-bit glibc runtime (for example lib32gcc-s1) and retry." >&2
        return 1
    fi
}

# The first invocation bootstraps and replaces the client with the current
# version, which can exit non-zero, so a clean exit is retried.
bootstrap_steamcmd() {
    local attempt status

    for ((attempt = 1; attempt <= BOOTSTRAP_ATTEMPTS_MAX; attempt++)); do
        status=0
        HOME="${STEAMCMD_HOME}" "${STEAMCMD_INSTALL_DIR}/steamcmd.sh" +quit || status=$?

        if [[ ${status} -eq 0 ]]; then
            echo "SteamCMD is up to date."
            return 0
        fi

        echo "SteamCMD bootstrap attempt ${attempt} of ${BOOTSTRAP_ATTEMPTS_MAX} exited with status ${status}."
        sleep 2
    done

    echo "FATAL: SteamCMD failed to bootstrap after ${BOOTSTRAP_ATTEMPTS_MAX} attempts." >&2
    return 1
}

main() {
    if [[ "${RUNNER_OS:-Linux}" != "Linux" ]]; then
        echo "FATAL: This action currently supports Linux runners only." >&2
        exit 1
    fi

    mkdir -p "${STEAMCMD_INSTALL_DIR}" "${STEAMCMD_HOME}"

    ensure_32bit_runtime

    echo "Downloading SteamCMD from ${STEAMCMD_URL}"
    download "${STEAMCMD_URL}" "${STEAMCMD_ROOT}/steamcmd_linux.tar.gz"
    tar -xzf "${STEAMCMD_ROOT}/steamcmd_linux.tar.gz" -C "${STEAMCMD_INSTALL_DIR}"
    rm -f "${STEAMCMD_ROOT}/steamcmd_linux.tar.gz"
    chmod +x "${STEAMCMD_INSTALL_DIR}/steamcmd.sh"

    bootstrap_steamcmd

    echo "Downloading steam-totp from ${STEAM_TOTP_URL}"
    download "${STEAM_TOTP_URL}" "${STEAM_TOTP_BIN}"
    chmod +x "${STEAM_TOTP_BIN}"

    if [[ -n "${GITHUB_ENV:-}" ]]; then
        {
            echo "STEAMCMD_ROOT=${STEAMCMD_ROOT}"
            echo "STEAMCMD_HOME=${STEAMCMD_HOME}"
        } >> "${GITHUB_ENV}"
    fi

    echo "SteamCMD installed at ${STEAMCMD_INSTALL_DIR}."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi