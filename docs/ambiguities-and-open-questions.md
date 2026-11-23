# Ambiguities And Open Questions

## Confirmed Implementation Gaps

| Finding | Evidence | Operational Impact |
|---|---|---|
| Raw VDF interpolation | [Four-field heredoc](../entrypoint.sh) | Quotes or newlines in `changenote` can alter descriptor syntax |
| No committed CI workflow | Reviewed tracked inventory | The unit suite is not enforced automatically; only the `latest` tag workflow is committed |
| No local timeout/lock/cleanup | [Entrypoint](../entrypoint.sh) | Callers and infrastructure must supply these controls |
| Unpinned client download | [Installer](../scripts/install-steamcmd.sh) | Client revision and integrity are not fixed by the repository |

## Contradictory Root Claims

- [README](../README.md), [architecture](../ARCHITECTURE.md), and [privacy](../PRIVACY.md) describe a finite three-attempt retry policy, which the implementation and its regression test now enforce.
- [Architecture](../ARCHITECTURE.md) describes workflow-based testing, but no test-enforcing workflow is committed. The unit suite exists but runs only when invoked manually; the only repository-owned workflow force-moves the `latest` tag.
- [Architecture](../ARCHITECTURE.md) describes complete ephemeral cleanup and no external dependencies. The installer leaves the client and its session under the runner's temporary directory and depends on the Steam CDN, GitHub Releases, and package repositories.
- [Privacy policy](../PRIVACY.md) gives strong seed/storage/cleanup statements. The wrapper passes the seed to a local helper and does not intentionally put it in VDF, but external binary behaviour, client session files, inherited environment, and runner retention were not verified.

Root documents were assessed and retained unchanged in this documentation-only task except where stated. These qualifications are recorded here rather than silently treating policy prose as executable evidence. No roadmap exists in the reviewed tree; none was invented.

## Unresolved Questions

| Question | Evidence Needed |
|---|---|
| Which Steam Guard configurations work with helper v1.0.1? | Version-specific helper documentation/source and authorized account integration |
| Which base/client versions, users, and libraries are actually resolved? | Digest-pinned client inspection and runtime inventory |
| Can specific nonzero client outcomes still publish? | Controlled failure injection plus remote-state verification |
| Which client files contain credentials/session material? | Safe isolated client filesystem review |
| Which runner architectures and service responses are supported? | Maintainer-defined matrix and integration evidence |
| What should finite retry semantics be: attempts or additional retries? | Explicit maintainer contract plus tests |
| Which log data and retention settings are acceptable? | Runner/operator policy and redacted sample review |

No live publication, network capture, dependency audit, or helper reverse engineering was performed. Do not interpret unknowns as proof of safety or failure.
