#!/bin/bash
# Test suite for entrypoint.sh
# Tests retry counter, input validation, credential redaction, TOTP validation, and error handling.

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
ENTRYPOINT="${REPO_ROOT}/entrypoint.sh"
INSTALL_SCRIPT="${REPO_ROOT}/scripts/install-steamcmd.sh"

# --- Test framework ---

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

assert_eq() {
    local desc="$1"
    local expected="$2"
    local actual="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$expected" == "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}PASS${NC}: $desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$desc")
        echo -e "${RED}FAIL${NC}: $desc"
        echo -e "  Expected: $expected"
        echo -e "  Actual:   $actual"
    fi
}

assert_contains() {
    local desc="$1"
    local haystack="$2"
    local needle="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$haystack" == *"$needle"* ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}PASS${NC}: $desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$desc")
        echo -e "${RED}FAIL${NC}: $desc"
        echo -e "  Expected to contain: $needle"
        echo -e "  In: $haystack"
    fi
}

assert_not_contains() {
    local desc="$1"
    local haystack="$2"
    local needle="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$haystack" != *"$needle"* ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}PASS${NC}: $desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$desc")
        echo -e "${RED}FAIL${NC}: $desc"
        echo -e "  Should NOT contain: $needle"
        echo -e "  In: $haystack"
    fi
}

assert_exit_code() {
    local desc="$1"
    local expected_code="$2"
    local actual_code="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$expected_code" == "$actual_code" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}PASS${NC}: $desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$desc")
        echo -e "${RED}FAIL${NC}: $desc"
        echo -e "  Expected exit code: $expected_code"
        echo -e "  Actual exit code:   $actual_code"
    fi
}

# --- Test helpers ---

# Source the entrypoint functions without executing the main body.
# We do this by extracting functions and sourcing them in a controlled way.
load_entrypoint_functions() {
    # Extract function definitions only (lines from function name to closing brace)
    local tmpfile
    tmpfile=$(mktemp)
    sed -n '/^sanitize_output()/,/^}/p' "$ENTRYPOINT" > "$tmpfile"
    sed -n '/^log_sanitized_cmd()/,/^}/p' "$ENTRYPOINT" >> "$tmpfile"
    sed -n '/^validate_input()/,/^}/p' "$ENTRYPOINT" >> "$tmpfile"
    sed -n '/^resolve_preview_file()/,/^}/p' "$ENTRYPOINT" >> "$tmpfile"
    sed -n '/^resolve_image_tooling()/,/^}/p' "$ENTRYPOINT" >> "$tmpfile"
    sed -n '/^downscale_preview_file()/,/^}/p' "$ENTRYPOINT" >> "$tmpfile"
    sed -n '/^run_steamcmd()/,/^}/p' "$ENTRYPOINT" >> "$tmpfile"
    source "$tmpfile"
    rm -f "$tmpfile"
}

# ImageMagick is an external prerequisite; skip the image-shaping suites when it
# is unavailable rather than reporting a false failure.
image_tooling_available() {
    command -v magick >/dev/null 2>&1 || { command -v convert >/dev/null 2>&1 && command -v identify >/dev/null 2>&1; }
}

create_test_image() {
    local file="$1"
    local width="$2"
    local height="$3"

    if command -v magick >/dev/null 2>&1; then
        magick -size "${width}x${height}" xc:white "$file"
    else
        convert -size "${width}x${height}" xc:white "$file"
    fi
}

read_test_image_dimensions() {
    local file="$1"

    if command -v magick >/dev/null 2>&1; then
        magick identify -format '%w %h' "${file}[0]"
    else
        identify -format '%w %h' "${file}[0]"
    fi
}

# --- Test suites ---

test_sanitize_output() {
    echo -e "\n${YELLOW}=== Test Suite: sanitize_output ===${NC}"

    STEAM_PASSWORD="secret123"
    STEAM_2FACODE="ABC123"
    STEAM_2FASEED="myseed"

    local result
    result=$(sanitize_output "test secret123 test ABC123 myseed")
    assert_contains "Password redacted in output" "$result" "***REDACTED***"
    assert_not_contains "No plaintext password in output" "$result" "secret123"
    assert_not_contains "No plaintext TOTP code in output" "$result" "ABC123"
    assert_not_contains "No plaintext seed in output" "$result" "myseed"
}

test_validate_input_numeric() {
    echo -e "\n${YELLOW}=== Test Suite: validate_input (numeric) ===${NC}"

    # Valid numeric
    (validate_input "appid" "123456" "numeric") >/dev/null 2>&1
    assert_exit_code "Valid numeric appid accepted" "0" "$?"

    # Invalid numeric (non-numeric)
    (validate_input "appid" "abc" "numeric") >/dev/null 2>&1
    assert_exit_code "Non-numeric appid rejected" "1" "$?"

    # Invalid numeric (empty)
    (validate_input "appid" "" "numeric") >/dev/null 2>&1
    assert_exit_code "Empty appid rejected" "1" "$?"

    # Invalid numeric (negative)
    (validate_input "appid" "-123" "numeric") >/dev/null 2>&1
    assert_exit_code "Negative appid rejected" "1" "$?"
}

test_validate_input_path() {
    echo -e "\n${YELLOW}=== Test Suite: validate_input (path) ===${NC}"

    local tmpdir
    tmpdir=$(mktemp -d)

    # Valid path within workspace
    GITHUB_WORKSPACE="$tmpdir"
    (validate_input "path" "$tmpdir" "path") >/dev/null 2>&1
    assert_exit_code "Valid path accepted" "0" "$?"

    # Path traversal attempt
    (validate_input "path" "/etc" "path") >/dev/null 2>&1
    assert_exit_code "Path outside workspace rejected" "1" "$?"

    # Non-existent path
    (validate_input "path" "/nonexistent/path" "path") >/dev/null 2>&1
    assert_exit_code "Non-existent path rejected" "1" "$?"

    rm -rf "$tmpdir"
}

test_validate_input_changenote() {
    echo -e "\n${YELLOW}=== Test Suite: validate_input (changenote) ===${NC}"

    # Valid changenote
    (validate_input "changenote" "Updated workshop item" "changenote") >/dev/null 2>&1
    assert_exit_code "Valid changenote accepted" "0" "$?"

    # Empty changenote
    (validate_input "changenote" "" "changenote") >/dev/null 2>&1
    assert_exit_code "Empty changenote rejected" "1" "$?"

    # Changenote too long
    local long_note
    long_note=$(printf 'x%.0s' {1..1001})
    (validate_input "changenote" "$long_note" "changenote") >/dev/null 2>&1
    assert_exit_code "Overly long changenote rejected" "1" "$?"
}

test_validate_input_image() {
    echo -e "\n${YELLOW}=== Test Suite: validate_input (image) ===${NC}"

    local tmpdir
    tmpdir=$(mktemp -d)
    GITHUB_WORKSPACE="$tmpdir"

    touch "$tmpdir/thumbnail.png"

    # Valid image within workspace
    (validate_input "icon" "$tmpdir/thumbnail.png" "image") >/dev/null 2>&1
    assert_exit_code "Existing image accepted" "0" "$?"

    # Missing file
    (validate_input "icon" "$tmpdir/absent.png" "image") >/dev/null 2>&1
    assert_exit_code "Missing image rejected" "1" "$?"

    # Directory is not a file
    (validate_input "icon" "$tmpdir" "image") >/dev/null 2>&1
    assert_exit_code "Directory rejected as image" "1" "$?"

    # Path traversal attempt
    touch "$(dirname "$tmpdir")/outside.png"
    (validate_input "icon" "$(dirname "$tmpdir")/outside.png" "image") >/dev/null 2>&1
    assert_exit_code "Image outside workspace rejected" "1" "$?"
    rm -f "$(dirname "$tmpdir")/outside.png"

    # Empty icon
    (validate_input "icon" "" "image") >/dev/null 2>&1
    assert_exit_code "Empty image rejected" "1" "$?"

    rm -rf "$tmpdir"
}

test_resolve_preview_file() {
    echo -e "\n${YELLOW}=== Test Suite: resolve_preview_file ===${NC}"

    local tmpdir
    tmpdir=$(mktemp -d)
    GITHUB_WORKSPACE="$tmpdir"
    mkdir -p "${tmpdir}/dist"

    # No icon and no recognised filename
    INPUT_ICON=""
    INPUT_PATH="dist"
    resolve_preview_file
    assert_eq "No preview image detected" "" "$PREVIEW_FILE"

    # Explicit icon takes precedence over detection
    touch "${tmpdir}/custom.png"
    touch "${tmpdir}/dist/thumbnail.png"
    INPUT_ICON="custom.png"
    resolve_preview_file
    assert_eq "Explicit icon preferred" "$(realpath "${tmpdir}/custom.png")" "$PREVIEW_FILE"

    # Detection honours the recognition order
    INPUT_ICON=""
    resolve_preview_file
    assert_eq "thumbnail.png detected" "$(realpath "${tmpdir}/dist/thumbnail.png")" "$PREVIEW_FILE"

    rm -f "${tmpdir}/dist/thumbnail.png"
    touch "${tmpdir}/dist/icon.png"
    touch "${tmpdir}/dist/thumb.png"
    resolve_preview_file
    assert_eq "icon.png preferred over thumb.png" "$(realpath "${tmpdir}/dist/icon.png")" "$PREVIEW_FILE"

    rm -rf "$tmpdir"
}

test_resolve_image_tooling() {
    echo -e "\n${YELLOW}=== Test Suite: resolve_image_tooling ===${NC}"

    resolve_image_tooling

    if ! image_tooling_available; then
        echo -e "${YELLOW}SKIP${NC}: ImageMagick not installed; cannot assert tooling resolution"
        return
    fi

    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ ${#IMAGE_CONVERT_CMD[@]} -gt 0 && ${#IMAGE_IDENTIFY_CMD[@]} -gt 0 ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}PASS${NC}: ImageMagick entry points resolved"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("ImageMagick entry points resolved")
        echo -e "${RED}FAIL${NC}: ImageMagick entry points resolved"
    fi
}

test_downscale_preview_file() {
    echo -e "\n${YELLOW}=== Test Suite: downscale_preview_file ===${NC}"

    if ! image_tooling_available; then
        echo -e "${YELLOW}SKIP${NC}: ImageMagick not installed; skipping downscale suite"
        return
    fi

    local tmpdir
    tmpdir=$(mktemp -d)
    PREVIEW_MAX_DIMENSION=512
    STEAMCMD_ROOT="${tmpdir}/steamcmd"
    PREVIEW_DOWNSCALED_FILE="${STEAMCMD_ROOT}/preview"
    mkdir -p "${STEAMCMD_ROOT}"
    resolve_image_tooling

    # No preview resolved: nothing to do
    PREVIEW_FILE=""
    downscale_preview_file
    assert_exit_code "Absent preview needs no downscaling" "0" "$?"

    # Oversized landscape image is scaled proportionally
    create_test_image "${tmpdir}/wide.png" 1024 512
    PREVIEW_FILE="${tmpdir}/wide.png"
    downscale_preview_file
    assert_exit_code "Oversized landscape image downscaled" "0" "$?"
    assert_eq "Landscape dimensions fit the limit" "512 256" "$(read_test_image_dimensions "${PREVIEW_FILE}")"
    assert_contains "Downscaled copy is used" "$PREVIEW_FILE" "${STEAMCMD_ROOT}/preview"

    # Oversized square image becomes the exact limit
    create_test_image "${tmpdir}/square.png" 800 800
    PREVIEW_FILE="${tmpdir}/square.png"
    downscale_preview_file
    assert_eq "Square dimensions fit the limit" "512 512" "$(read_test_image_dimensions "${PREVIEW_FILE}")"

    # Oversized portrait image is scaled proportionally
    create_test_image "${tmpdir}/tall.png" 512 1024
    PREVIEW_FILE="${tmpdir}/tall.png"
    downscale_preview_file
    assert_eq "Portrait dimensions fit the limit" "256 512" "$(read_test_image_dimensions "${PREVIEW_FILE}")"

    # Image within the limit is left untouched
    create_test_image "${tmpdir}/small.png" 256 256
    PREVIEW_FILE="${tmpdir}/small.png"
    downscale_preview_file
    assert_exit_code "Within-limit image accepted" "0" "$?"
    assert_eq "Within-limit image left unchanged" "${tmpdir}/small.png" "$PREVIEW_FILE"

    # An exact-limit image is also left untouched
    create_test_image "${tmpdir}/exact.png" 512 512
    PREVIEW_FILE="${tmpdir}/exact.png"
    downscale_preview_file
    assert_eq "Exact-limit image left unchanged" "${tmpdir}/exact.png" "$PREVIEW_FILE"

    # A non-image file has no readable dimensions
    printf 'not an image' > "${tmpdir}/broken.png"
    PREVIEW_FILE="${tmpdir}/broken.png"
    downscale_preview_file >/dev/null 2>&1
    assert_exit_code "Unreadable image rejected" "1" "$?"

    # Without ImageMagick the function fails instead of silently skipping the limit
    PREVIEW_FILE="${tmpdir}/small.png"
    IMAGE_IDENTIFY_CMD=()
    downscale_preview_file >/dev/null 2>&1
    assert_exit_code "Missing ImageMagick is fatal" "1" "$?"
    resolve_image_tooling

    rm -rf "$tmpdir"
}

test_retry_counter() {
    echo -e "\n${YELLOW}=== Test Suite: Retry Counter ===${NC}"

    local loop_source
    loop_source=$(sed -n '/^# Attempt loop/,/^done$/p' "$ENTRYPOINT")

    if [[ -z "$loop_source" ]]; then
        assert_eq "Retry loop found in entrypoint.sh" "present" "missing"
        return
    fi

    # Persistent failure must stop after ATTEMPTS_MAX invocations, even under
    # errexit, which is exactly what the old implementation failed to do.
    local failures_output attempts
    failures_output=$(
        set -e
        ATTEMPTS_MAX=3
        run_steamcmd() { return 1; }
        sleep() { :; }
        eval "$loop_source"
    ) 2>/dev/null

    run_steamcmd() { return 1; }
    attempts=$(printf '%s\n' "$failures_output" | grep -c '^Attempt [0-9]* of 3\.\.\.$')

    assert_eq "Persistent failure runs exactly 3 attempts" "3" "$attempts"

    local success_output
    success_output=$(
        set -e
        ATTEMPTS_MAX=3
        run_steamcmd() { return 0; }
        sleep() { :; }
        eval "$loop_source"
    )

    attempts=$(printf '%s\n' "$success_output" | grep -c '^Attempt [0-9]* of 3\.\.\.$')
    assert_eq "Success stops after one attempt" "1" "$attempts"
}

test_totp_validation() {
    echo -e "\n${YELLOW}=== Test Suite: TOTP Validation ===${NC}"

    # Valid TOTP codes (5-6 alphanumeric)
    local valid_codes=("ABC12" "ABC123" "12345" "123456" "a1b2c3")
    for code in "${valid_codes[@]}"; do
        if [[ "$code" =~ ^[A-Za-z0-9]{5,6}$ ]]; then
            TESTS_RUN=$((TESTS_RUN + 1))
            TESTS_PASSED=$((TESTS_PASSED + 1))
            echo -e "${GREEN}PASS${NC}: Valid TOTP code '$code' accepted"
        else
            TESTS_RUN=$((TESTS_RUN + 1))
            TESTS_FAILED=$((TESTS_FAILED + 1))
            FAILED_TESTS+=("Valid TOTP code '$code' should be accepted")
            echo -e "${RED}FAIL${NC}: Valid TOTP code '$code' should be accepted"
        fi
    done

    # Invalid TOTP codes
    local invalid_codes=("ABC1" "ABC1234" "ABC-12" "ABC 12" "" "ABC12!")
    for code in "${invalid_codes[@]}"; do
        if [[ "$code" =~ ^[A-Za-z0-9]{5,6}$ ]]; then
            TESTS_RUN=$((TESTS_RUN + 1))
            TESTS_FAILED=$((TESTS_FAILED + 1))
            FAILED_TESTS+=("Invalid TOTP code '$code' should be rejected")
            echo -e "${RED}FAIL${NC}: Invalid TOTP code '$code' should be rejected"
        else
            TESTS_RUN=$((TESTS_RUN + 1))
            TESTS_PASSED=$((TESTS_PASSED + 1))
            echo -e "${GREEN}PASS${NC}: Invalid TOTP code '$code' rejected"
        fi
    done
}

test_run_steamcmd_argument_array() {
    echo -e "\n${YELLOW}=== Test Suite: run_steamcmd Argument Array ===${NC}"

    # Verify that run_steamcmd uses argument arrays (no eval)
    local content
    content=$(cat "$ENTRYPOINT")

    assert_not_contains "No eval in entrypoint" "$content" "eval "
    assert_contains "Uses local -a for argument array" "$content" "local -a steamcmd_args"
    assert_contains "Uses array expansion for execution" "$content" '"${steamcmd_args[@]}"'
}

test_strict_mode() {
    echo -e "\n${YELLOW}=== Test Suite: Strict Mode ===${NC}"

    local content
    content=$(cat "$ENTRYPOINT")

    assert_contains "set -euo pipefail present in entrypoint" "$content" "set -euo pipefail"

    content=$(cat "$INSTALL_SCRIPT")
    assert_contains "set -euo pipefail present in installer" "$content" "set -euo pipefail"
}

test_no_container_execution() {
    echo -e "\n${YELLOW}=== Test Suite: Native Execution ===${NC}"

    # The action must not run SteamCMD through Docker, whose default seccomp
    # profile breaks the 32-bit client on Docker 29.4.2.
    local action_content
    action_content=$(cat "${REPO_ROOT}/action.yml")

    assert_contains "Action uses composite execution" "$action_content" "using: 'composite'"
    assert_not_contains "Action does not build a Docker image" "$action_content" "image: 'Dockerfile'"
    assert_contains "Inputs are mapped to INPUT_ environment variables" "$action_content" "INPUT_APPID: \${{ inputs.appid }}"

    local content
    content=$(cat "$ENTRYPOINT")
    assert_not_contains "Entrypoint does not rely on the container Steam home" "$content" "/home/steam"
}

test_exit_codes() {
    echo -e "\n${YELLOW}=== Test Suite: Exit Codes ===${NC}"

    local content
    content=$(cat "$ENTRYPOINT")

    assert_contains "Exit 0 on success" "$content" "exit 0"
    assert_contains "Exit 2 on failure" "$content" "exit 2"
    assert_contains "Exit 1 on validation failure" "$content" "exit 1"
}

test_log_sanitization() {
    echo -e "\n${YELLOW}=== Test Suite: Log Sanitization ===${NC}"

    local content
    content=$(cat "$ENTRYPOINT")

    assert_contains "sanitize_output function defined" "$content" "sanitize_output()"
    assert_contains "log_sanitized_cmd function defined" "$content" "log_sanitized_cmd()"
    assert_contains "Steam logs are read from the Steam home" "$content" 'LOG_DIR="${STEAMCMD_HOME}/Steam/logs"'
    assert_contains "Failure paths print both Steam logs" "$content" "for log_name in stderr.txt workshop_log.txt; do"
}

# --- Main ---

main() {
    echo "========================================"
    echo "  entrypoint.sh Test Suite"
    echo "========================================"

    load_entrypoint_functions

    test_sanitize_output
    test_validate_input_numeric
    test_validate_input_path
    test_validate_input_changenote
    test_validate_input_image
    test_resolve_preview_file
    test_resolve_image_tooling
    test_downscale_preview_file
    test_retry_counter
    test_totp_validation
    test_run_steamcmd_argument_array
    test_strict_mode
    test_no_container_execution
    test_exit_codes
    test_log_sanitization

    echo ""
    echo "========================================"
    echo "  Test Summary"
    echo "========================================"
    echo "  Total:   $TESTS_RUN"
    echo -e "  ${GREEN}Passed:  $TESTS_PASSED${NC}"
    echo -e "  ${RED}Failed:  $TESTS_FAILED${NC}"
    echo "========================================"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "\n${RED}Failed tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo "  - $test"
        done
        exit 1
    fi

    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
}

main "$@"
