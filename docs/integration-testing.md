# Integration Testing Guide

This document describes how to run integration tests for the `steam-workshop-update` GitHub Action.

## Overview

Integration tests verify actual Steam Workshop API interactions using real Steam credentials and a real workshop item. These tests require:

1. A dedicated Steam test account (NOT your main account)
2. A workshop item owned by that account that you have permission to update
3. The AppID that owns the workshop item
4. Optional: Steam Guard 2FA seed for TOTP authentication testing

## Security Warning

**NEVER use production credentials for integration testing.**

- Create a dedicated Steam account for testing
- Use a workshop item that can be safely modified
- Never commit `config.env` with real credentials
- The `config.env` file is gitignored

## Setup

### 1. Create a Test Steam Account

Create a new Steam account specifically for integration testing. Do not use your main account.

### 2. Create a Test Workshop Item

1. Log into Steam with the test account
2. Create a workshop item for a game you own (or use an existing one)
3. Note the **AppID** (game ID) and **PublishedFileID** (workshop item ID)
4. Ensure the test account has permission to update this item

### 3. Configure Integration Tests

```bash
# Copy the example configuration
cp tests/integration/config.env.example tests/integration/config.env

# Edit with your test credentials
nano tests/integration/config.env
```

Fill in all required fields:
- `STEAM_USERNAME` - Your test Steam username
- `STEAM_PASSWORD` - Your test Steam password
- `STEAM_APPID` - The AppID of the game owning the workshop item
- `STEAM_ITEMID` - The PublishedFileID of the workshop item to update
- `STEAM_WORKSPACE_PATH` - Path where test content will be created (default is fine)
- `STEAM_2FASEED` - Optional: Steam Guard 2FA seed for TOTP testing

### 4. Get Steam Guard 2FA Seed (Optional)

If you want to test TOTP authentication:

1. Enable Steam Guard Mobile Authenticator on the test account
2. Use a tool like `steam-totp` or the Steam Desktop Authenticator to extract the shared secret
3. The seed is typically a base32-encoded string (e.g., `ABCDEF1234567890`)

## Running Integration Tests

### Prerequisites

- Docker installed and running
- The `steam-workshop-update` Docker image built locally

```bash
# Build the Docker image
docker build -t steam-workshop-update:local .
```

### Run Tests

```bash
# Run all integration tests
bash tests/integration/run_integration_tests.sh

# Or run with custom config location
INTEGRATION_CONFIG=/path/to/config.env bash tests/integration/run_integration_tests.sh
```

### Test Suite

The integration test suite includes:

| Test | Description |
|------|-------------|
| `test_workshop_update_success` | Basic workshop update with valid credentials |
| `test_workshop_update_with_changenote` | Verifies changenote is included in update |
| `test_workshop_update_idempotency` | Verifies repeated updates with same content succeed |
| `test_invalid_credentials` | Verifies proper failure handling with bad credentials |
| `test_invalid_appid` | Verifies handling of non-existent AppID |
| `test_invalid_itemid` | Verifies handling of non-existent ItemID |
| `test_totp_authentication` | Tests TOTP/2FA authentication (requires STEAM_2FASEED) |
| `test_credential_redaction_in_logs` | Verifies no plaintext credentials in output |

## CI/CD Integration

Integration tests are **not** run automatically in CI/CD pipelines because they require real Steam credentials. They are intended for:

- Local development validation
- Pre-release manual verification
- Testing with dedicated test infrastructure

To run in a controlled CI environment:

1. Store test credentials in GitHub Secrets (or equivalent)
2. Create a separate workflow file (e.g., `.github/workflows/integration-tests.yml`)
3. Run only on manual trigger or scheduled basis
4. Use a dedicated test Steam account and workshop item

Example workflow snippet:

```yaml
name: Integration Tests
on:
  workflow_dispatch:
  schedule:
    - cron: '0 2 * * 0'  # Weekly on Sunday

jobs:
  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build image
        run: docker build -t steam-workshop-update:local .
      - name: Run integration tests
        env:
          STEAM_USERNAME: ${{ secrets.INTEGRATION_STEAM_USERNAME }}
          STEAM_PASSWORD: ${{ secrets.INTEGRATION_STEAM_PASSWORD }}
          STEAM_2FASEED: ${{ secrets.INTEGRATION_STEAM_2FASEED }}
          STEAM_APPID: ${{ secrets.INTEGRATION_STEAM_APPID }}
          STEAM_ITEMID: ${{ secrets.INTEGRATION_STEAM_ITEMID }}
        run: |
          cat > tests/integration/config.env << EOF
          STEAM_USERNAME=$STEAM_USERNAME
          STEAM_PASSWORD=$STEAM_PASSWORD
          STEAM_2FASEED=$STEAM_2FASEED
          STEAM_APPID=$STEAM_APPID
          STEAM_ITEMID=$STEAM_ITEMID
          STEAM_WORKSPACE_PATH=/home/horatiu/Proiecte/github-actions/steam-workshop-update/tests/integration/test_content
          EOF
          bash tests/integration/run_integration_tests.sh
```

## Troubleshooting

### "Configuration file not found"

Ensure you've copied `config.env.example` to `config.env` and filled in all required fields.

### "Required configuration variable X is not set"

Check that all required variables are set in `config.env` with no typos.

### Tests fail with "exit code 2"

This is expected for negative tests (invalid credentials, invalid AppID/ItemID). Check the test output for details.

### "TOTP code validation failed"

- Ensure `STEAM_2FASEED` is correct
- Verify the system clock is synchronized (TOTP is time-sensitive)
- Check that the Steam account has Mobile Authenticator enabled

### Rate limiting

Steam may rate limit repeated API calls. The test suite includes a 5-second delay between idempotency test runs. If you encounter rate limiting:

- Wait longer between test runs
- Reduce test frequency
- Use a different test workshop item

## Test Fixtures

The test suite automatically creates a test content directory at `STEAM_WORKSPACE_PATH` with a simple text file. This directory is cleaned up after tests complete.

To customize test content, modify the `setup_test_fixture()` function in `run_integration_tests.sh`.

## Adding New Integration Tests

1. Add a new test function following the naming pattern `test_<name>`
2. Use the assertion helpers (`assert_eq`, `assert_contains`, `assert_exit_code`)
3. Set required environment variables before calling `entrypoint.sh`
4. Call your new test function in the `main()` function
5. Update this documentation

## Cleanup

After testing, you may want to:

1. Delete the test workshop item (or revert changes)
2. Revoke the test account's API access if applicable
3. Remove `config.env` (it's gitignored but good practice)

## Related Documentation

- [Testing Strategy](./testing.md) - Overall testing approach
- [Change Guide](./change-guide.md) - How to validate changes
- [Security](./security.md) - Security considerations