# Documentation Maintenance

## Ownership And Review

Owner: repository maintainers; contributors changing an implementation contract must update its documentation. This is a maintenance responsibility, not evidence of a formally assigned documentation team. Last reviewed: 2026-10-29.

Coverage includes every tracked production/configuration source in the reviewed repository, local control flow, external tool boundaries, and root-document discrepancies. Coverage does not include external binary internals, a built-image inventory, or live Steam publication.

## Source Of Truth

Executable behaviour comes from [entrypoint](../entrypoint.sh), [metadata](../action.yml), and [Dockerfile](../Dockerfile). Root policies remain the source for reporting, licensing, and declared privacy commitments. Documentation must distinguish observed wrapper behaviour, inferred external assumptions, and unknowns.

Keep the [master index](./INDEX.md) exhaustive. Every documentation file must have a linked catalogue entry; new pages must link evidence and related contracts. Link to root policies instead of copying them. Do not create a second architecture overview, roadmap, privacy policy, security notice, or licence in this directory.

## Update Triggers

| Change | Pages To Revisit |
|---|---|
| Inputs/defaults | [Configuration](./configuration.md), [data model](./data-model.md), [examples](./api-usage-examples.md) |
| Command order/authentication | [Entrypoint](./components/entrypoint.md), [tool contracts](./components/external-tools.md), [flows](./flows/workshop-update.md) |
| Retry/exit fix | [Retry analysis](./flows/retries-and-exit-status.md), [invariants](./invariants.md), [errors](./error-handling.md), [testing](./testing.md), [FAQ](./faq.md) |
| Files/dependencies/runtime user | [Image component](./components/container-image.md), [dependencies](./dependencies.md), [state](./state-and-persistence.md), [security](./security.md) |
| Log or credential handling | [Logging](./logging.md), [security](./security.md), root policy accuracy |
| New tests/workflows | [Testing](./testing.md), [deployment](./build-and-deployment.md), [structure](./repository-structure.md), [open questions](./ambiguities-and-open-questions.md) |

## Validation Discipline

Check relative links against existing targets, catalogue coverage, Markdown fences/headings, and diff whitespace. Re-run focused behavioural checks for claims that changed. Never promote ephemeral mocks into a claim of committed test coverage or a successful live integration.

Assess [README](../README.md), [architecture](../ARCHITECTURE.md), [security policy](../SECURITY.md), and [privacy policy](../PRIVACY.md) when related behaviour changes; use their applicable templates when editing them. Root files remain unchanged in this generation; their known discrepancies are explicitly recorded in [open questions](./ambiguities-and-open-questions.md).
