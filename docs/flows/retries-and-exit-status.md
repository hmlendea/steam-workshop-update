# Retries And Exit Status

## Intended And Actual Limit

The [entrypoint](../../entrypoint.sh) initialises `ATTEMPTS_CURRENT=0`, `ATTEMPTS_MAX=3`, and `IS_SUCCESSFUL=0`. It loops while the current counter is below the maximum. The failure assignment is:

```bash
ATTEMPTS_CURRENT=$((ATTEMPTS+1))
```

It reads `ATTEMPTS`, which the script never initialises, rather than `ATTEMPTS_CURRENT`. Bash arithmetic treats an unset variable as zero here because nounset is not enabled.

With ordinary `ATTEMPTS` unset:
1. The first iteration prints `Attempt 1 of 3...`.
2. Failure sets the counter to one and prints `Attempt 1 failed. Retrying...`.
3. Every subsequent iteration prints `Attempt 2 of 3...`.
4. Each subsequent failure resets the counter to one, sleeps two seconds, and repeats indefinitely.

Thus the implementation has neither three total attempts nor three retries in the normal persistent-failure case. Success can still break the loop at any iteration. External job cancellation or timeout can end it; no local deadline exists.

## Ambient Environment Effect

For a stable numeric inherited `ATTEMPTS`, every failure assigns that value plus one. Values at least two can cause the loop to terminate after its first failure; smaller values can retain an unbounded loop. Untrusted or malformed arithmetic input is not validated. Do not use this accidental variable as a supported retry setting.

## Exit Contract

| Outcome | Script Status | Important Qualification |
|---|---|---|
| Missing username/password | `1` | Before descriptor generation |
| Helper/client returns zero as appropriate | `0` | No independent remote publication check |
| Loop finishes without success | `2` | Normally unreachable on persistent failure with `ATTEMPTS` unset |
| Cancellation, runtime launch failure, arithmetic failure | Environment-dependent | Not normalized to the explicit application statuses |

The terminal failure block prints `stderr.txt` and `workshop_log.txt` from `/home/steam/Steam/logs/`, then exits two. A missing log file produces a `cat` diagnostic but does not replace that explicit final status. Even the final failed iteration sleeps before leaving the loop.

## Reproduction Evidence

A bounded Bash harness extracted the actual loop, mocked `run_steamcmd` to fail and `sleep` to return immediately, removed ambient `ATTEMPTS`, and aborted before a fifth failure. It observed the counter remaining one and repeated `Attempt 2 of 3...` messages. Separate in-memory mocks with inherited `ATTEMPTS=2` reached the terminal status-two block for both helper and client failures.

These were documentation-time checks, not a committed automated suite. Production logic was not changed. A future fix should test exact total invocation counts, final delays, eventual success, helper failures, and immunity to ambient `ATTEMPTS`; see [testing](../testing.md).
