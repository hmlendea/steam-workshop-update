# Design Decisions And Trade-Offs

No formal ADRs or original decision history are present. The following distinctions separate source-observed choices from inferred benefits and costs; they do not attribute undocumented intent to maintainers.

| Observed Choice | Evidence | Inferred Trade-Off |
|---|---|---|
| Package as Docker action | [Metadata](../action.yml), [Dockerfile](../Dockerfile) | Bundles runtime/client assumptions; requires compatible runner and image build |
| Delegate upload to SteamCMD | [Command construction](../entrypoint.sh) | Avoids implementing Valve protocol; success and diagnostics depend on external client |
| Generate VDF locally | [Heredoc](../entrypoint.sh) | Simple metadata bridge; needs escaping, validation, and write gating that are currently absent |
| Optional helper rather than mandatory 2FA branch | [run_steamcmd](../entrypoint.sh) | Supports password-only command form; no automated fallback/challenge handling |
| Repeat whole login/upload command | [Loop](../entrypoint.sh) | Can recover transient failure; repeats authentication and potentially remote side effects |
| Use status zero as success | [Success flag](../entrypoint.sh) | Simple runner contract; no independent publication evidence |
| Print descriptor and eventual client logs | [Output statements](../entrypoint.sh) | Useful diagnosis versus disclosure and output-volume risk |
| Fixed helper release, floating base | [Image inputs](../Dockerfile) | Partial version selection without reproducible full dependency closure |

## Not Deliberate Decisions Without Evidence

The counter typo is an implementation defect, not a proven intentional infinite-retry policy. Missing validation, tests, checksums, locks, and cleanup are current absences, not documented decisions to reject those features.

The [root architecture](../ARCHITECTURE.md) calls the action a containerised microservice. Operationally, source shows a short-lived synchronous command orchestrator with no server or service endpoint. This clarification does not require generating a duplicate architecture document.

Future trade-off changes should include regression evidence, user-visible contract impact, and a clear distinction between wrapper guarantees and external-client assumptions. See [change guide](./change-guide.md).
