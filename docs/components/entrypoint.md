# Entrypoint Orchestrator

## Purpose And Boundary

[entrypoint.sh](../../entrypoint.sh) coordinates one requested Workshop update. It owns local setup and command sequencing; it does not build the mod, implement Steam authentication protocols, parse client logs for success, or verify remote content.

[Action metadata](../../action.yml) invokes it as `bash "${GITHUB_ACTION_PATH}/entrypoint.sh"` after [scripts/install-steamcmd.sh](../../scripts/install-steamcmd.sh) has installed the client. It assumes Bash, a writable `${STEAMCMD_ROOT}` (default `${RUNNER_TEMP}/steamcmd`), the client at `${STEAMCMD_ROOT}/install/steamcmd.sh`, the helper at `${STEAMCMD_ROOT}/steam-totp`, accessible workspace content, and outbound Steam connectivity.

## Top-Level Execution

1. Resolve `${GITHUB_WORKSPACE}`, `${STEAMCMD_ROOT}`, `${STEAMCMD_HOME}`, the client path, the helper path, the log directory, and the descriptor path.
2. Check `STEAM_USERNAME` for empty/unset; emit a fatal message and exit one if missing.
3. Check `STEAM_PASSWORD` the same way, then require an executable client.
4. Validate `appid` and `itemid` as numeric, the workspace-relative content path for existence and containment, and `changenote` for printable characters and length. Validate an explicitly supplied `icon` as an existing file inside the workspace.
5. Resolve the preview image, preferring the explicit `icon` and otherwise probing the content directory for a recognised filename.
6. Overwrite `${STEAMCMD_ROOT}/workshop.vdf` from the input variables and workspace path, adding `previewfile` only when a preview image resolves, then print it.
7. Initialise loop state and invoke `run_steamcmd` inside an `if` condition.
8. On status zero, set `IS_SUCCESSFUL=1`, break, and exit zero.
9. On failure, increment the counter, print a retry message, and delay two seconds unless the budget is exhausted.
10. If the loop terminates without success, print two client log files and exit two.

`set -euo pipefail` is enabled, so an untested command failure stops the script. Descriptor generation is not gated explicitly, but a write failure now terminates execution before the client runs.

## Function Contract

`run_steamcmd` reads credentials and optional seed from shell environment. It invokes the client directly without a seed. With a seed, it enables invariant .NET globalization, captures helper stdout, checks the helper's status, validates the 5-6 character alphanumeric code shape, and returns one without invoking SteamCMD if either check fails.

Otherwise, the function's last command is SteamCMD, run with `HOME` set to `${STEAMCMD_HOME}`, so its return status is the client status. The outer loop treats every nonzero status identically; authentication errors and upload errors are not distinguished.

## State And Side Effects

The descriptor is generated once, not per attempt. Each attempt repeats login and the upload command. A seeded attempt generates a new code. Output streams are inherited; child output reaches the workflow log. There is no lock, rollback, signal trap, cleanup routine, or explicit timeout.

## Modification Impact

Changing credential names affects [configuration](../configuration.md) and callers. Changing VDF generation affects [data contracts](../data-model.md), output disclosure, and client compatibility. Changing preview selection affects descriptor fields and detection order. Changing retry logic affects job duration, diagnostic reachability, and repeated remote side effects. Use [focused test scenarios](../testing.md), not a live item, to verify orchestration first.
