# State And Persistence

## State Inventory

| State | Reader/Writer | Lifetime And Caveats |
|---|---|---|
| Workflow content directory | Caller writes; SteamCMD reads | Mounted workspace; action does not delete or snapshot it |
| `/home/steam/workshop.vdf` | Entrypoint writes/prints; SteamCMD reads | Overwritten once per invocation; no explicit deletion |
| Credential environment | Runner supplies; script/helper/client inherit | Process lifetime; host/process inspection remains a trust boundary |
| Generated `STEAM_2FACODE` | Function writes; SteamCMD receives | Shell variable, overwritten on later seeded calls; not explicitly cleared |
| Retry counters and success flag | Script only | In-memory invocation state; no resume record |
| Steam client state and logs | External SteamCMD | Exact files/retention depend on upstream client and runtime |
| Published Workshop content | Steam service | Remote side effect survives local process/container termination |
| Workflow logs | Runner captures output | Host/platform retention; not removed by script exit |

## Persistence Semantics

No database, cache abstraction, migration, event store, or repository-managed durable session storage exists. This does not mean that SteamCMD never writes authentication/session files. Its internals were not inspected, and its writable client directories can contain state.

The [script](../entrypoint.sh) has no `rm`, cleanup trap, or credential-file erasure. Normal container removal is an infrastructure lifecycle, not a script guarantee. Self-hosted runner storage, Docker layers, mounted workspace files, and retained job logs need operator-specific review. See [root privacy policy](../PRIVACY.md) and [implementation security analysis](./security.md).

## Consistency And Recovery

Descriptor generation is a direct overwrite, not an atomic replace. A write failure is not gated; an old file could remain when reusing a filesystem. Retrying preserves the descriptor but does not freeze its content directory. The script neither rolls back a partial remote operation nor queries whether a failed invocation actually published.

Recovery is a new invocation with caller-provided content/configuration. It does not resume local counters or a known remote transaction. Protect against overlap using caller-level [concurrency controls](./concurrency-and-scheduling.md).
