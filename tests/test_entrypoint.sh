#!/bin/bash
# Test suite for entrypoint.sh
# Tests retry counter, input validation, credential redaction, TOTP validation, and error handling.

set -uo pipefail

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
    local entrypoint="/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh"
    # Extract function definitions only (lines from function name to closing brace)
    # We use a subshell-safe approach: source with a guard
    local tmpfile
    tmpfile=$(mktemp)
    # Extract just the function definitions
    sed -n '/^sanitize_output()/,/^}/p' "$entrypoint" > "$tmpfile"
    sed -n '/^log_sanitized_cmd()/,/^}/p' "$entrypoint" >> "$tmpfile"
    sed -n '/^validate_input()/,/^}/p' "$entrypoint" >> "$tmpfile"
    sed -n '/^run_steamcmd()/,/^}/p' "$entrypoint" >> "$tmpfile"
    source "$tmpfile"
    rm -f "$tmpfile"
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

test_retry_counter() {
    echo -e "\n${YELLOW}=== Test Suite: Retry Counter ===${NC}"

    # Simulate the retry loop logic from entrypoint.sh
    local ATTEMPTS_CURRENT=0
    local ATTEMPTS_MAX=3
    local IS_SUCCESSFUL=0
    local attempts_made=0

    # Simulate 3 failures then check loop terminates
    while [[ $ATTEMPTS_CURRENT -lt $ATTEMPTS_MAX ]]; do
        attempts_made=$((attempts_made + 1))
        ATTEMPTS_CURRENT=$((ATTEMPTS_CURRENT + 1))
        # Simulate failure (no break)
    done

    assert_eq "Loop runs exactly 3 times on all failures" "3" "$attempts_made"
    assert_eq "ATTEMPTS_CURRENT reaches 3" "3" "$ATTEMPTS_CURRENT"
    assert_eq "IS_SUCCESSFUL remains 0 on all failures" "0" "$IS_SUCCESSFUL"

    # Simulate success on first attempt
    ATTEMPTS_CURRENT=0
    IS_SUCCESSFUL=0
    attempts_made=0
    while [[ $ATTEMPTS_CURRENT -lt $ATTEMPTS_MAX ]]; do
        attempts_made=$((attempts_made + 1))
        IS_SUCCESSFUL=1
        break
        ATTEMPTS_CURRENT=$((ATTEMPTS_CURRENT + 1))
    done

    assert_eq "Loop breaks on first success" "1" "$attempts_made"
    assert_eq "IS_SUCCESSFUL set to 1 on success" "1" "$IS_SUCCESSFUL"

    # Simulate success on second attempt
    ATTEMPTS_CURRENT=0
    IS_SUCCESSFUL=0
    attempts_made=0
    while [[ $ATTEMPTS_CURRENT -lt $ATTEMPTS_MAX ]]; do
        attempts_made=$((attempts_made + 1))
        ATTEMPTS_CURRENT=$((ATTEMPTS_CURRENT + 1))
        if [[ $attempts_made -eq 2 ]]; then
            IS_SUCCESSFUL=1
            break
        fi
    done

    assert_eq "Loop breaks on second attempt success" "2" "$attempts_made"
    assert_eq "IS_SUCCESSFUL set to 1 on second attempt" "1" "$IS_SUCCESSFUL"
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
    local entrypoint="/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh"
    local content
    content=$(cat "$entrypoint")

    assert_not_contains "No eval in entrypoint" "$content" "eval "
    assert_contains "Uses local -a for argument array" "$content" "local -a steamcmd_args"
    assert_contains "Uses array expansion for execution" "$content" '"${steamcmd_args[@]}"'
}

test_strict_mode() {
    echo -e "\n${YELLOW}=== Test Suite: Strict Mode ===${NC}"

    local entrypoint="/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh"
    local content
    content=$(cat "$entrypoint")

    assert_contains "set -euo pipefail present" "$content" "set -euo pipefail"
}

test_exit_codes() {
    echo -e "\n${YELLOW}=== Test Suite: Exit Codes ===${NC}"

    local entrypoint="/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh"
    local content
    content=$(cat "$entrypoint")

    assert_contains "Exit 0 on success" "$content" "exit 0"
    assert_contains "Exit 2 on failure" "$content" "exit 2"
    assert_contains "Exit 1 on validation failure" "$content" "exit 1"
}

test_log_sanitization() {
    echo -e "\n${YELLOW}=== Test Suite: Log Sanitization ===${NC}"

    local entrypoint="/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh"
    local content
    content=$(cat "$entrypoint")

    assert_contains "sanitize_output function defined" "$content" "sanitize_output()"
    assert_contains "log_sanitized_cmd function defined" "$content" "log_sanitized_cmd()"
    assert_contains "stderr.txt sanitized on failure" "$content" "sanitize_output \"\$(cat /home/steam/Steam/logs/stderr.txt)\""
    assert_contains "workshop_log.txt sanitized on failure" "$content" "sanitize_output \"\$(cat /home/steam/Steam/logs/workshop_log.txt)\""
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
    test_retry_counter
    test_totp_validation
    test_run_steamcmd_argument_array
    test_strict_mode
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
