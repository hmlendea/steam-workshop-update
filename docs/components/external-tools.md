# External Tool Contracts

## SteamCMD

The [entrypoint's](../../entrypoint.sh) `run_steamcmd` function invokes `/home/steam/steamcmd/steamcmd.sh` with this argument sequence:

```text
+@ShutdownOnFailedCommand 1
+login USERNAME PASSWORD [GENERATED_CODE]
+workshop_build_item /home/steam/workshop.vdf
+quit
```

Each credential is passed as one quoted shell argument. The client receives the VDF pathname rather than metadata fields as separate upload arguments. The descriptor directs the client to the content directory. Authentication, transport, upload, permission checks, session persistence, and service diagnostics are delegated to SteamCMD.

`+@ShutdownOnFailedCommand 1` requests fail-fast client command handling. The repository does not verify how every client version implements it. The script observes only process status; it does not parse output, detect interactive prompts, or check remote completion independently.

## Two-Factor Helper

When `STEAM_2FASEED` is nonempty, the script exports `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1` and executes `/home/steam/steam-totp` with the seed as a single argument. Command substitution captures stdout, removes trailing newlines, and assigns `STEAM_2FACODE`. Stderr is not captured. Nonzero helper status returns one immediately; zero status permits login even if stdout is empty or malformed.

The [image](../../Dockerfile) installs release `v1.0.1`, Linux x64. The [README](../../README.md) describes a standard TOTP seed, not a Steam Guard base64 secret. This investigation did not inspect the helper implementation or verify seed compatibility; do not derive further cryptographic guarantees from its name.

## Shared Operational Limits

Both commands run synchronously, with inherited output and no wrapper timeout. Clock correctness matters to time-based code usefulness, but the action does not synchronize or validate time. Network policy, account authorization, Steam Guard challenges, and client state can affect success outside the script's control.

For failure propagation, see [authentication flow](../flows/authentication.md) and [error handling](../error-handling.md). External binaries are not repository-owned substitutes for tests of command construction.
