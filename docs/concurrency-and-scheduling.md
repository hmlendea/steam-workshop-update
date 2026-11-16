# Concurrency And Scheduling

## Local Ordering

The [entrypoint](../entrypoint.sh) runs one synchronous Bash control flow. Helper execution completes before SteamCMD starts; SteamCMD completes before status inspection and any retry delay. There are no background jobs, async tasks, queues, threads, or internal schedulers implemented here. External tools may have their own concurrency, which was not inspected.

Descriptor generation occurs once before the loop. Each failed attempt except the last incurs `sleep 2`, so a persistent failure now completes in bounded time ([retry policy](./flows/retries-and-exit-status.md)); a hanging client can still prevent progress independently.

## Cross-Invocation Hazards

Separate workflow runs can update the same Workshop item concurrently. There is no distributed lock, lease, item-version check, or conflict handling. On a persistent self-hosted runner, sharing `${STEAMCMD_ROOT}` across concurrent jobs can also make multiple processes overwrite the same descriptor and client state.

The repository defines no workflow triggers or scheduling policy. The calling workflow owns cron/manual/push triggers, `timeout-minutes`, job ordering, and GitHub Actions `concurrency` groups. Prefer serialization by target item and explicit job timeouts; cancellation can interrupt an upload and does not undo remote effects.

## Time Dependencies

The optional helper generates time-based codes. Host clock correctness and accepted Steam authentication windows are external prerequisites. The script does not wait for a fresh code window or distinguish rate limiting from other failures. A two-second local delay is not a remote backoff policy.

When modifying retries, review repeated authentication load, item update overlap, eventual-success semantics, and [failure tests](./testing.md) together.
