# Invariants And Contracts

## Implemented Contracts

| Contract | Evidence | Dependants |
|---|---|---|
| Empty username/password prevents client invocation | Ordered checks in [entrypoint](../entrypoint.sh) | Callers diagnosing configuration failures |
| Invalid inputs are rejected before any upload | `validate_input` calls before descriptor generation | Callers diagnosing configuration failures |
| VDF precedes client invocation and uses a stable pathname | Heredoc before loop; `+workshop_build_item` argument | Client path resolution |
| Credentials are absent from intentionally generated VDF fields | Five-field heredoc | Descriptor disclosure assumptions; caller values can still contain sensitive text |
| `previewfile` appears only when a preview image resolves | Conditional heredoc in [entrypoint](../entrypoint.sh) | Client descriptor compatibility; no field is emitted otherwise |
| Nonempty seed requires a valid helper result before client call | `run_steamcmd` early return | Authentication flow and secret handling |
| Every seeded invocation regenerates its code | Helper call inside function | Retry behaviour and time assumptions |
| Client zero status ends the loop successfully | `if run_steamcmd` check and success flag | GitHub step success |
| Failures stop after three attempts | Loop counter tested by [tests/test_entrypoint.sh](../tests/test_entrypoint.sh) | Job duration and output volume |
| No structured output is produced | No output declaration or output-file write | Downstream steps must use status, not invented result fields |

## Assumptions, Not Enforced Invariants

| Desired Property | Current Limitation |
|---|---|
| Valid descriptor content | No VDF escaping for quotes or newlines |
| Exactly one publication | Full command repeated; no reconciliation or idempotency token |
| No overlapping updates | No lock; caller must serialize |
| No secret disclosure | `sanitize_output` redacts known credential values in wrapper output; command arguments and external output remain a boundary |
| Complete cleanup | No cleanup trap; installed client and session files persist for the runner lifetime |
| Published content equals a snapshot | No content copy, digest, or freeze |

## Safe Modification Rule

Preserve the implemented contracts unless explicitly changing the public interface. Do not silently elevate an assumption into a documented guarantee. Pair a corrected invariant with a focused test and update the [flow](./flows/workshop-update.md), [failure guide](./error-handling.md), and [configuration](./configuration.md).
