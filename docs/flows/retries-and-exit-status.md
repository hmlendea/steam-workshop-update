# Retries And Exit Status

## Retry Policy

The [entrypoint](../../entrypoint.sh) initialises `ATTEMPTS_CURRENT=0` and `IS_SUCCESSFUL=0`, then increments the counter at the start of each iteration while it is below `ATTEMPTS_MAX` (three). The client command is tested directly:

```bash
if run_steamcmd; then
    IS_SUCCESSFUL=1
    break
fi
```

Because the command is used as an `if` condition, a failed attempt is retried instead of terminating the script through `errexit`. `set -euo pipefail` is enabled, so an unrelated untested failure still stops execution.

Observed behaviour:
1. The first iteration prints `Attempt 1 of 3...`.
2. A failure prints `Attempt 1 failed.` followed by `Retrying...` and a two-second delay.
3. At most three invocations occur; the delay is skipped after the final attempt.
4. Success at any iteration breaks the loop, then the script waits a fixed `POST_UPLOAD_COOLDOWN_SECONDS` (30) delay before exiting zero, allowing the remote item to settle.

There is no local deadline and no exponential backoff beyond the fixed two-second retry delay and the fixed post-upload cooldown.

## Exit Contract

| Outcome | Script Status | Important Qualification |
|---|---|---|
| Missing username/password | `1` | Before descriptor generation |
| Missing SteamCMD installation | `1` | Before descriptor generation |
| Invalid `appid`, `itemid`, `path`, `changenote`, or `icon` | `1` | Before descriptor generation |
| Helper/client returns zero as appropriate | `0` | Waits a 30-second post-upload cooldown; no independent remote publication check |
| All three attempts fail | `2` | Prints both Steam log files first |
| Cancellation, signal termination, arithmetic failure | Environment-dependent | Not normalized to the explicit application statuses |

The terminal failure block prints `stderr.txt` and `workshop_log.txt` from `${STEAMCMD_HOME}/Steam/logs/`, then exits two. A missing log file is reported as not found and does not replace that explicit final status.

## Reproduction Evidence

[tests/test_entrypoint.sh](../../tests/test_entrypoint.sh) extracts the real loop text from the entrypoint, mocks `run_steamcmd` and `sleep`, and asserts that persistent failure produces exactly three `Attempt N of 3...` lines and that immediate success produces exactly one. The suite requires no credentials, network access, or SteamCMD.

Residual gaps: the suite does not observe real client statuses, retry timing against a live service, or remote publication side effects; see [testing](../testing.md).
