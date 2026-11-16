# Design Decisions And Trade-Offs

No formal ADRs or original decision history are present. The following distinctions separate source-observed choices from inferred benefits and costs; they do not attribute undocumented intent to maintainers.

| Observed Choice | Evidence | Inferred Trade-Off |
|---|---|---|
| Package as composite action | [Metadata](../action.yml) | Runs SteamCMD natively, avoiding the Docker 29.4.2 seccomp deny that breaks the 32-bit client; requires a Linux runner and 32-bit runtime availability |
| Delegate upload to SteamCMD | [Command construction](../entrypoint.sh) | Avoids implementing Valve protocol; success and diagnostics depend on external client |
| Generate VDF locally | [Heredoc](../entrypoint.sh) | Simple metadata bridge; needs escaping, validation, and write gating that are currently absent |
| Optional helper rather than mandatory 2FA branch | [run_steamcmd](../entrypoint.sh) | Supports password-only command form; no automated fallback/challenge handling |
| Repeat whole login/upload command | [Loop](../entrypoint.sh) | Can recover transient failure; repeats authentication and potentially remote side effects |
| Use status zero as success | [Success flag](../entrypoint.sh) | Simple runner contract; no independent publication evidence |
| Print descriptor and eventual client logs | [Output statements](../entrypoint.sh) | Useful diagnosis versus disclosure and output-volume risk |
| Fixed helper release, unpinned client download | [Installer inputs](../scripts/install-steamcmd.sh) | Partial version selection without reproducible full dependency closure |

## Not Deliberate Decisions Without Evidence

Missing checksums, locks, and cleanup are current absences, not documented decisions to reject those features. The earlier retry-counter typo was corrected and is now covered by a regression test.

The [root architecture](../ARCHITECTURE.md) previously described the action as a containerised microservice. Operationally, source shows a short-lived synchronous command orchestrator with no server or service endpoint. This clarification does not require generating a duplicate architecture document.

Future trade-off changes should include regression evidence, user-visible contract impact, and a clear distinction between wrapper guarantees and external-client assumptions. See [change guide](./change-guide.md).
