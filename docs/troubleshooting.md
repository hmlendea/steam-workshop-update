# Troubleshooting

| Symptom | Causal Explanation | Safe Next Check |
|---|---|---|
| Fatal missing username/password | Empty environment; Docker defaults are empty | Confirm secret binding names without printing values |
| Job repeatedly prints `Attempt 2 of 3...` | Counter resets to one after each failure | Stop job; inspect sanitized earlier output; see [retry defect](./flows/retries-and-exit-status.md) |
| No final Steam log dump | Infinite failure loop or blocked child prevents terminal block | Check job timeout/client progress; do not assume logs were filtered |
| Helper failure before any login | Seed branch returns one on helper nonzero | Verify installed helper compatibility and redacted stderr |
| Login fails despite helper zero | Code format unchecked, account/challenge/time conditions external | Check clock and authorized helper/account setup; never share seed/code |
| Invalid descriptor/client parse error | Unescaped quotes/newlines or incomplete input | Review sanitized generated VDF against [schema](./data-model.md) |
| Content folder missing | Workspace/path prefix mismatch or content not prepared | Confirm mounted workspace and relative directory before calling action |
| VDF write error followed by login | Runtime script ignores write status | Inspect permissions and fixed target; avoid stale-file reuse |
| Upload permission failure | App/item/account assumptions delegated to Steam | Verify target ownership and authorization outside action |
| Build fails fetching helper/packages | Build-time network/provenance dependencies | Inspect build error, registry/apt/GitHub access, and asset URL |
| Local Docker run immediately exits one | No credentials supplied | Treat as validation smoke check, not failed upload integration |
| Step succeeds but remote state is unexpected | Success is client zero status only | Independently inspect intended Workshop item/content |

## Diagnostic Hygiene

Do not enable shell tracing or print environment variables with live credentials. The generated descriptor and external logs may contain sensitive user-supplied content or session information. Redact before sharing, and follow the [security reporting policy](../SECURITY.md) for suspected vulnerabilities.

Verify remote state before rerunning an ambiguous failed upload. A local failure may follow a remote side effect, and no rollback or idempotency mechanism exists. Use [error semantics](./error-handling.md), [logging behaviour](./logging.md), and [authentication flow](./flows/authentication.md) to narrow the cause rather than changing all configuration at once.
