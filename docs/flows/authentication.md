# Authentication Flow

## Branch Decision

In [entrypoint.sh](../../entrypoint.sh), `run_steamcmd` branches on whether `STEAM_2FASEED` is empty. Username and password have already passed nonempty checks, but are not otherwise validated.

| Condition | Execution | Status Observed By Loop |
|---|---|---|
| Seed empty/unset | SteamCMD login with username and password, then upload and quit | SteamCMD status |
| Seed supplied; helper succeeds | Enable invariant globalization; capture helper stdout; validate the 5-6 character alphanumeric shape; login with username, password, and generated code; upload and quit | SteamCMD status |
| Seed supplied; helper fails or emits a malformed code | Return one without running client | One |

No fallback from failed helper generation to password-only login exists. No email challenge handler, interactive input protocol, saved-session import, or alternative authenticator is implemented by this script. Any client interaction beyond its command arguments belongs to SteamCMD and may block or fail.

## Data Boundaries

The helper gets the seed as an argument; SteamCMD gets the generated code, not the seed argument. Both inherit the shell environment, so the seed remains available in the client process environment. The script does not scrub credentials, clear the generated code, mask helper output, or register it as a GitHub secret.

Helper stdout becomes a single quoted login argument after Bash removes trailing newlines. Exit zero and a matching 5-6 character alphanumeric shape are both required; the check accepts a wrong-but-well-formed code, because it cannot confirm correctness. Stderr passes through directly to the job log.

## Time And Retries

Every seeded retry calls the helper again. A new invocation does not guarantee a different code within the same time interval. The two-second retry delay does not align to a new interval, and there is no clock-skew detection. Persistent generation failure exhausts the retry budget ([retry policy](./retries-and-exit-status.md)) before any client call.

## Evidence

[tests/test_entrypoint.sh](../../tests/test_entrypoint.sh) covers the code-shape matcher, and documentation-time mocks verified that failed generation prevents the client call. No actual code was generated, credentials supplied, or Steam login attempted. Helper internals and live Steam Guard compatibility remain [unverified](../ambiguities-and-open-questions.md).
