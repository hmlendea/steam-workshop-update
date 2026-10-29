# Entrypoint Orchestrator

## Purpose And Boundary

[entrypoint.sh](../../entrypoint.sh) coordinates one requested Workshop update. It owns local setup and command sequencing; it does not build the mod, implement Steam authentication protocols, parse client logs for success, or verify remote content.

Docker invokes its Bash shebang through `ENTRYPOINT`. Its positional arguments, including the image's default `.`, are unused. It assumes Bash, writable `/home/steam`, installed executables at fixed paths, accessible workspace content, and outbound Steam connectivity.

## Top-Level Execution

1. Check `STEAM_USERNAME` for empty/unset; emit a fatal message and exit one if missing.
2. Check `STEAM_PASSWORD` the same way.
3. Overwrite `/home/steam/workshop.vdf` from four input variables and workspace path.
4. Print the complete descriptor to stdout.
5. Initialise loop state and invoke `run_steamcmd`.
6. On status zero, set `IS_SUCCESSFUL=1`, break, and exit zero.
7. On failure, assign a counter from the wrong variable, print a retry message, and delay two seconds.
8. If the loop terminates without success, print two client log files and exit two.

Steps three and four are not checked for failure. There is no `set -e`, `set -u`, or `pipefail`; command failure alone does not stop the script. A failed descriptor write can therefore be followed by SteamCMD against a missing or pre-existing descriptor.

## Function Contract

`run_steamcmd` reads credentials and optional seed from shell environment. It invokes the client directly without a seed. With a seed, it enables invariant .NET globalization, captures helper stdout, checks the helper's status, and returns one without invoking SteamCMD if generation failed.

Otherwise, the function's last command is SteamCMD, so its return status is the client status. The outer loop treats every nonzero status identically; authentication errors and upload errors are not distinguished.

## State And Side Effects

The descriptor is generated once, not per attempt. Each attempt repeats login and the upload command. A seeded attempt generates a new code. Output streams are inherited; child output reaches the workflow log. There is no lock, rollback, signal trap, cleanup routine, or explicit timeout.

## Modification Impact

Changing credential names affects [configuration](../configuration.md) and callers. Changing VDF generation affects [data contracts](../data-model.md), output disclosure, and client compatibility. Changing retry logic affects job duration, diagnostic reachability, and repeated remote side effects. Use [focused test scenarios](../testing.md), not a live item, to verify orchestration first.
