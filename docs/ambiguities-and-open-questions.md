# Ambiguities And Open Questions

## Confirmed Implementation Gaps

| Finding | Evidence | Operational Impact |
|---|---|---|
| Retry counter reads wrong variable | [Entrypoint](../entrypoint.sh), [bounded reproduction](./flows/retries-and-exit-status.md) | Persistent failure normally never reaches terminal diagnostics |
| VDF write/print errors ignored | [Entrypoint](../entrypoint.sh) has no gating/strict mode | Missing, partial, or stale descriptor can reach client |
| Raw VDF interpolation | [Four-field heredoc](../entrypoint.sh) | Invalid syntax or altered field structure from input |
| No committed tests or CI workflow | Reviewed tracked inventory; [contribution guide](../CONTRIBUTING.md) | Runtime claims lack ongoing regression enforcement |
| No local timeout/lock/cleanup/redaction | [Entrypoint](../entrypoint.sh) | Callers and infrastructure must supply these controls |

## Contradictory Root Claims

- [README](../README.md), [architecture](../ARCHITECTURE.md), and [privacy](../PRIVACY.md) describe a finite three-attempt retry policy; current ordinary failure behaviour contradicts it.
- [Architecture](../ARCHITECTURE.md) describes workflow-based testing, but no repository-owned workflow is committed. Historical/external testing is unknown.
- [Contribution guide](../CONTRIBUTING.md) recommends `set -euo pipefail`; production script does not enable it.
- [Architecture](../ARCHITECTURE.md) describes complete ephemeral cleanup and no external dependencies. Source contains no cleanup mechanism and explicitly depends on external image/package/helper acquisition and Steam runtime services.
- [Privacy policy](../PRIVACY.md) gives strong seed/storage/cleanup statements. The wrapper passes the seed to a local helper and does not intentionally put it in VDF, but external binary behaviour, client session files, inherited environment, and runner retention were not verified.

Root documents were assessed and retained unchanged in this documentation-only task. These qualifications are recorded here rather than silently treating policy prose as executable evidence. No roadmap exists in the reviewed tree; none was invented.

## Unresolved Questions

| Question | Evidence Needed |
|---|---|
| Which Steam Guard configurations work with helper v1.0.1? | Version-specific helper documentation/source and authorized account integration |
| Which base/client versions, users, and libraries are actually resolved? | Digest-pinned image inspection and runtime inventory |
| Can specific nonzero client outcomes still publish? | Controlled failure injection plus remote-state verification |
| Which client files contain credentials/session material? | Safe isolated client filesystem review |
| Which runner architectures and service responses are supported? | Maintainer-defined matrix and integration evidence |
| What should finite retry semantics be: attempts or additional retries? | Explicit maintainer contract plus tests |
| Which log data and retention settings are acceptable? | Runner/operator policy and redacted sample review |

No live publication, network capture, dependency audit, or helper reverse engineering was performed. Do not interpret unknowns as proof of safety or failure.
