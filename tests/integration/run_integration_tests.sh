#!/bin/bash
# Integration test runner for steam-workshop-update
# Tests actual Steam Workshop API interactions with test credentials.
# Requires explicit configuration with test Steam account and authorized workshop item.

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration file path
CONFIG_FILE="${INTEGRATION_CONFIG:-/home/horatiu/Proiecte/github-actions/steam-workshop-update/tests/integration/config.env}"

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# --- Helper functions ---

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

assert_eq() {
    local desc="$1"
    local expected="$2"
    local actual="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$expected" == "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        log_pass "$desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$desc")
        log_fail "$desc"
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
        log_pass "$desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$desc")
        log_fail "$desc"
        echo -e "  Expected to contain: $needle"
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
        log_pass "$desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$desc")
        log_fail "$desc"
        echo -e "  Expected exit code: $expected_code"
        echo -e "  Actual exit code:   $actual_code"
    fi
}

# --- Configuration loading ---

load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_fail "Configuration file not found: $CONFIG_FILE"
        log_info "Copy config.env.example to config.env and fill in your test credentials"
        exit 1
    fi

    # shellcheck source=/dev/null
    source "$CONFIG_FILE"

    # Validate required configuration
    local required_vars=(
        "STEAM_USERNAME"
        "STEAM_PASSWORD"
        "STEAM_APPID"
        "STEAM_ITEMID"
        "STEAM_WORKSPACE_PATH"
    )

    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            log_fail "Required configuration variable $var is not set in $CONFIG_FILE"
            exit 1
        fi
    done

    # Optional: STEAM_2FASEED for 2FA testing
    if [[ -n "${STEAM_2FASEED:-}" ]]; then
        log_info "2FA seed configured - will test TOTP authentication"
    else
        log_info "No 2FA seed configured - testing password-only authentication"
    fi

    log_info "Configuration loaded successfully"
    log_info "AppID: $STEAM_APPID"
    log_info "ItemID: $STEAM_ITEMID"
    log_info "Workspace: $STEAM_WORKSPACE_PATH"
}

# --- Test fixtures ---

setup_test_fixture() {
    log_info "Setting up test fixture..."

    # Create test content directory
    mkdir -p "$STEAM_WORKSPACE_PATH"

    # Create a simple test file
    cat > "$STEAM_WORKSPACE_PATH/test_content.txt" << EOF
Steam Workshop Integration Test
Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Test run ID: ${TEST_RUN_ID:-$(date +%s)}
EOF

    log_info "Test fixture created at $STEAM_WORKSPACE_PATH"
}

cleanup_test_fixture() {
    log_info "Cleaning up test fixture..."
    rm -rf "$STEAM_WORKSPACE_PATH"
    log_info "Test fixture cleaned up"
}

# --- Integration tests ---

test_workshop_update_success() {
    log_info "Running integration test: Workshop update success"

    # Set environment variables for entrypoint.sh
    export STEAM_USERNAME
    export STEAM_PASSWORD
    export STEAM_2FASEED="${STEAM_2FASEED:-}"
    export INPUT_APPID="$STEAM_APPID"
    export INPUT_ITEMID="$STEAM_ITEMID"
    export INPUT_PATH="$(basename "$STEAM_WORKSPACE_PATH")"
    export INPUT_CHANGENOTE="Integration test update - $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    export GITHUB_WORKSPACE="$(dirname "$STEAM_WORKSPACE_PATH")"

    # Run the entrypoint script
    local output
    output=$(/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh 2>&1)
    local exit_code=$?

    # Check exit code
    assert_exit_code "Workshop update exits with code 0 on success" "0" "$exit_code"

    # Verify output contains success indicators
    assert_contains "Output shows attempt started" "$output" "Attempt 1 of 3"
    assert_contains "Output shows success" "$output" "exit 0"

    log_info "Workshop update completed successfully"
}

test_workshop_update_with_changenote() {
    log_info "Running integration test: Workshop update with changenote verification"

    export STEAM_USERNAME
    export STEAM_PASSWORD
    export STEAM_2FASEED="${STEAM_2FASEED:-}"
    export INPUT_APPID="$STEAM_APPID"
    export INPUT_ITEMID="$STEAM_ITEMID"
    export INPUT_PATH="$(basename "$STEAM_WORKSPACE_PATH")"
    export INPUT_CHANGENOTE="Integration test changenote verification - $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    export GITHUB_WORKSPACE="$(dirname "$STEAM_WORKSPACE_PATH")"

    local output
    output=$(/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh 2>&1)
    local exit_code=$?

    assert_exit_code "Workshop update with changenote exits with code 0" "0" "$exit_code"
    assert_contains "Output shows changenote in VDF" "$output" "changenote"
}

test_workshop_update_idempotency() {
    log_info "Running integration test: Workshop update idempotency (second run)"

    export STEAM_USERNAME
    export STEAM_PASSWORD
    export STEAM_2FASEED="${STEAM_2FASEED:-}"
    export INPUT_APPID="$STEAM_APPID"
    export INPUT_ITEMID="$STEAM_ITEMID"
    export INPUT_PATH="$(basename "$STEAM_WORKSPACE_PATH")"
    export INPUT_CHANGENOTE="Integration test idempotency - $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    export GITHUB_WORKSPACE="$(dirname "$STEAM_WORKSPACE_PATH")"

    # First run
    local output1
    output1=$(/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh 2>&1)
    local exit_code1=$?
    assert_exit_code "First run succeeds" "0" "$exit_code1"

    # Small delay to avoid rate limiting
    sleep 5

    # Second run with same content
    local output2
    output2=$(/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh 2>&1)
    local exit_code2=$?
    assert_exit_code "Second run succeeds (idempotent)" "0" "$exit_code2"

    log_info "Idempotency test passed - both runs succeeded"
}

test_invalid_credentials() {
    log_info "Running integration test: Invalid credentials handling"

    export STEAM_USERNAME="invalid_user_$(date +%s)"
    export STEAM_PASSWORD="invalid_password"
    export STEAM_2FASEED=""
    export INPUT_APPID="$STEAM_APPID"
    export INPUT_ITEMID="$STEAM_ITEMID"
    export INPUT_PATH="$(basename "$STEAM_WORKSPACE_PATH")"
    export INPUT_CHANGENOTE="Integration test invalid credentials - $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    export GITHUB_WORKSPACE="$(dirname "$STEAM_WORKSPACE_PATH")"

    local output
    output=$(/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh 2>&1)
    local exit_code=$?

    # Should fail after 3 attempts
    assert_exit_code "Invalid credentials exits with code 2 after retries" "2" "$exit_code"
    assert_contains "Output shows all attempts failed" "$output" "All 3 attempts failed"
    assert_contains "Output shows retry attempts" "$output" "Attempt 1 of 3"
    assert_contains "Output shows retry attempts" "$output" "Attempt 2 of 3"
    assert_contains "Output shows retry attempts" "$output" "Attempt 3 of 3"

    log_info "Invalid credentials test passed - correctly fails after 3 attempts"
}

test_invalid_appid() {
    log_info "Running integration test: Invalid AppID handling"

    export STEAM_USERNAME
    export STEAM_PASSWORD
    export STEAM_2FASEED="${STEAM_2FASEED:-}"
    export INPUT_APPID="999999999"  # Non-existent app
    export INPUT_ITEMID="$STEAM_ITEMID"
    export INPUT_PATH="$(basename "$STEAM_WORKSPACE_PATH")"
    export INPUT_CHANGENOTE="Integration test invalid appid - $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    export GITHUB_WORKSPACE="$(dirname "$STEAM_WORKSPACE_PATH")"

    local output
    output=$(/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh 2>&1)
    local exit_code=$?

    # Should fail (either validation or Steam API error)
    assert_exit_code "Invalid AppID exits with non-zero code" "2" "$exit_code"
    assert_contains "Output shows failure" "$output" "failed"

    log_info "Invalid AppID test passed"
}

test_invalid_itemid() {
    log_info "Running integration test: Invalid ItemID handling"

    export STEAM_USERNAME
    export STEAM_PASSWORD
    export STEAM_2FASEED="${STEAM_2FASEED:-}"
    export INPUT_APPID="$STEAM_APPID"
    export INPUT_ITEMID="999999999999999999"  # Non-existent item
    export INPUT_PATH="$(basename "$STEAM_WORKSPACE_PATH")"
    export INPUT_CHANGENOTE="Integration test invalid itemid - $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    export GITHUB_WORKSPACE="$(dirname "$STEAM_WORKSPACE_PATH")"

    local output
    output=$(/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh 2>&1)
    local exit_code=$?

    # Should fail (either validation or Steam API error)
    assert_exit_code "Invalid ItemID exits with non-zero code" "2" "$exit_code"
    assert_contains "Output shows failure" "$output" "failed"

    log_info "Invalid ItemID test passed"
}

test_totp_authentication() {
    if [[ -z "${STEAM_2FASEED:-}" ]]; then
        log_warn "Skipping TOTP test - no 2FA seed configured"
        return 0
    fi

    log_info "Running integration test: TOTP authentication"

    export STEAM_USERNAME
    export STEAM_PASSWORD
    export STEAM_2FASEED
    export INPUT_APPID="$STEAM_APPID"
    export INPUT_ITEMID="$STEAM_ITEMID"
    export INPUT_PATH="$(basename "$STEAM_WORKSPACE_PATH")"
    export INPUT_CHANGENOTE="Integration test TOTP auth - $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    export GITHUB_WORKSPACE="$(dirname "$STEAM_WORKSPACE_PATH")"

    local output
    output=$(/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh 2>&1)
    local exit_code=$?

    assert_exit_code "TOTP authentication succeeds" "0" "$exit_code"
    assert_contains "Output shows TOTP validation" "$output" "TOTP code validation passed"

    log_info "TOTP authentication test passed"
}

test_credential_redaction_in_logs() {
    log_info "Running integration test: Credential redaction in logs"

    export STEAM_USERNAME
    export STEAM_PASSWORD
    export STEAM_2FASEED="${STEAM_2FASEED:-}"
    export INPUT_APPID="$STEAM_APPID"
    export INPUT_ITEMID="$STEAM_ITEMID"
    export INPUT_PATH="$(basename "$STEAM_WORKSPACE_PATH")"
    export INPUT_CHANGENOTE="Integration test credential redaction - $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    export GITHUB_WORKSPACE="$(dirname "$STEAM_WORKSPACE_PATH")"

    local output
    output=$(/home/horatiu/Proiecte/github-actions/steam-workshop-update/entrypoint.sh 2>&1)
    local exit_code=$?

    assert_exit_code "Workshop update succeeds" "0" "$exit_code"

    # Verify no plaintext credentials in output
    assert_not_contains "Password not in output" "$output" "$STEAM_PASSWORD"
    if [[ -n "${STEAM_2FASEED:-}" ]]; then
        assert_not_contains "2FA seed not in output" "$output" "$STEAM_2FASEED"
    fi

    log_info "Credential redaction test passed"
}

# --- Main ---

main() {
    echo "========================================"
    echo "  Steam Workshop Update - Integration Tests"
    echo "========================================"
    echo ""

    # Generate test run ID
    export TEST_RUN_ID="$(date +%s)"

    # Load configuration
    load_config

    # Setup test fixture
    setup_test_fixture

    # Run tests
    echo ""
    log_info "Starting integration test suite..."
    echo ""

    test_workshop_update_success
    test_workshop_update_with_changenote
    test_workshop_update_idempotency
    test_invalid_credentials
    test_invalid_appid
    test_invalid_itemid
    test_totp_authentication
    test_credential_redaction_in_logs

    # Cleanup
    cleanup_test_fixture

    # Summary
    echo ""
    echo "========================================"
    echo "  Integration Test Summary"
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

    echo -e "\n${GREEN}All integration tests passed!${NC}"
    exit 0
}

# Run main if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi