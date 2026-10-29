# Invariants And Contracts

## Implemented Contracts

| Contract | Evidence | Dependants |
|---|---|---|
| Empty username/password prevents client invocation | Ordered checks in [entrypoint](../entrypoint.sh) | Callers diagnosing configuration failures |
| VDF precedes client invocation and uses fixed pathname | Heredoc before loop; `+workshop_build_item` argument | Client path resolution and image permissions |
| Credentials are absent from intentionally generated VDF fields | Four-field heredoc | Descriptor disclosure assumptions; caller values can still contain sensitive text |
| Nonempty seed requires successful helper status before client call | `run_steamcmd` early return | Authentication flow and secret handling |
| Every seeded invocation regenerates its code | Helper call inside function | Retry behaviour and time assumptions |
| Client zero status ends the loop successfully | Immediate `$?` check and success flag | GitHub step success |
| No structured output is produced | No output declaration or output-file write | Downstream steps must use status, not invented result fields |

## Assumptions, Not Enforced Invariants

| Desired Property | Current Limitation |
|---|---|
| Finite failure budget | Counter references wrong variable; ordinary persistent failure is unbounded |
| Valid descriptor and content path | No escaping, validation, path containment, or write-status gate |
| Valid generated code | Helper status checked, stdout format unchecked |
| Exactly one publication | Full command repeated; no reconciliation or idempotency token |
| No overlapping updates | No lock; caller must serialize |
| No secret disclosure | No local redaction; external output and command arguments may expose data |
| Complete cleanup | No cleanup trap; runner/client lifecycle governs residual data |
| Published content equals a snapshot | No content copy, digest, or freeze |

## Safe Modification Rule

Preserve the implemented contracts unless explicitly changing the public interface. Do not silently elevate an assumption into a documented guarantee. Pair a corrected invariant with a focused test and update the [flow](./flows/workshop-update.md), [failure guide](./error-handling.md), and [configuration](./configuration.md).
