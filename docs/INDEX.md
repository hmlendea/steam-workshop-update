# Documentation Index

## Repository Summary

`steam-workshop-update` is a Docker-based GitHub Action that updates an existing Steam Workshop item through SteamCMD. A small Bash entrypoint validates credential presence, creates a VDF descriptor from workflow inputs, optionally generates a two-factor code, and invokes login/upload commands. This knowledge base traces actual data, control flow, state, failures, dependency boundaries, and safe modification points; it distinguishes wrapper guarantees from external-client assumptions and documents the current retry-counter defect.

## Start Here

- Newcomers: [Quick start](./quick-start.md) → [Configuration](./configuration.md) → [Usage examples](./api-usage-examples.md).
- Component owners: [Implementation map](./repository-structure.md) → [Entrypoint](./components/entrypoint.md) → [Contracts](./invariants.md) → [Change guide](./change-guide.md).
- Debuggers: [Upload flow](./flows/workshop-update.md) → [Authentication](./flows/authentication.md) → [Retries and status](./flows/retries-and-exit-status.md) → [Troubleshooting](./troubleshooting.md).
- Risk review: [Known gaps](./ambiguities-and-open-questions.md) → [Implementation security](./security.md) → [Logging](./logging.md).

## Root Document Map

| Root Document | Role |
|---|---|
| [README](../README.md) | Existing user-facing introduction and example |
| [Architecture](../ARCHITECTURE.md) | Existing architecture overview, complemented rather than duplicated here |
| [Security policy](../SECURITY.md) | Reporting, support, and disclosure policy |
| [Privacy policy](../PRIVACY.md) | Published data-handling policy |
| [Licence](../LICENSE) | GNU GPL version 3 licence text |
| [Contributing](../CONTRIBUTING.md) | Contribution process |
| [Code of conduct](../CODE_OF_CONDUCT.md) | Community conduct expectations |

No root roadmap exists in the reviewed tree. No roadmap, privacy policy, security notice, or licence copy is generated here. Source-verified discrepancies in existing root prose are indexed under [open questions](./ambiguities-and-open-questions.md).

## Documentation Catalogue

### Orientation And Operation

- [Documentation index](./INDEX.md) — Master navigation, catalogue, coverage, and review metadata.
- [Repository overview](./repository-overview.md) — Purpose, ownership, interface boundaries, and principal caveats.
- [Repository structure](./repository-structure.md) — Complete tracked-file map and source anchors.
- [Quick start](./quick-start.md) — Prerequisites and safe initial invocation sequence.
- [Configuration](./configuration.md) — Input/environment schema, defaults, transformations, and fixed settings.
- [Build and deployment](./build-and-deployment.md) — Image construction, runner constraints, verification levels, and caller duties.
- [Troubleshooting](./troubleshooting.md) — Symptoms, causal explanations, and safe next checks.
- [FAQ](./faq.md) — Answers to common interface and runtime misunderstandings.

### Components And Behaviour

- [Entrypoint orchestrator](./components/entrypoint.md) — Exact top-level sequencing, function contract, and side effects.
- [Container image](./components/container-image.md) — Dependency installation, executable layout, launch arguments, and trust assumptions.
- [External tool contracts](./components/external-tools.md) — SteamCMD and helper arguments, status handling, and delegated behaviour.
- [Workshop update behaviour](./behaviour/workshop-updates.md) — User-visible prerequisites, outcomes, and non-features.

### End-To-End Flows

- [Workshop update](./flows/workshop-update.md) — Caller input through descriptor, authentication, client upload, and observed completion.
- [Authentication](./flows/authentication.md) — Seeded/password-only branches, helper gating, and credential boundaries.
- [Retries and exit status](./flows/retries-and-exit-status.md) — Counter defect, ambient environment influence, diagnostics, and reproduction evidence.

### Interfaces, Data, And Integration

- [Interface reference](./api-reference/INDEX.md) — Explains absence of HTTP endpoints and maps the actual action interface.
- [Action usage examples](./api-usage-examples.md) — Workflow fragment, optional variations, and observable results.
- [Data model](./data-model.md) — VDF schema, transformations, credentials, and result semantics.
- [State and persistence](./state-and-persistence.md) — Workspace, descriptor, process, client, remote, and log lifecycles.
- [Concurrency and scheduling](./concurrency-and-scheduling.md) — Sequential execution, timing, overlaps, and caller controls.
- [Dependencies](./dependencies.md) — Build/runtime inventory, version selection, and upgrade implications.
- [Integrations](./integrations.md) — GitHub Actions, Valve/SteamCMD, and build-service boundaries.

### Contracts, Risk, And Maintenance

- [Invariants and contracts](./invariants.md) — Implemented guarantees distinguished from unvalidated assumptions.
- [Error handling](./error-handling.md) — Failure taxonomy, propagation, recovery, and missing gates.
- [Logging](./logging.md) — Output taxonomy, destinations, structure, correlation, masking, retention, and performance.
- [Implementation security](./security.md) — Trust boundaries, risks, recommendations, and unverified areas.
- [Testing](./testing.md) — Actual test baseline, performed checks, coverage limits, and regression matrix.
- [Design decisions](./design-decisions.md) — Source-observed choices and explicitly inferred trade-offs.
- [Change guide](./change-guide.md) — Ownership/impact map and focused validation for common changes.
- [Ambiguities and open questions](./ambiguities-and-open-questions.md) — Confirmed defects, root-document contradictions, and unresolved external contracts.
- [Documentation maintenance](./documentation-maintenance.md) — Ownership, source-of-truth rules, update triggers, and verification discipline.

## Maintenance Metadata

- Last reviewed: 2026-10-29.
- Owner: repository maintainers; contributors update affected contracts when changing implementation.
- Source coverage: all tracked production/configuration files; root architecture, contribution, security, and privacy documents assessed.
- Local verification: Bash syntax and bounded, in-memory control-flow mocks; see [testing evidence](./testing.md).
- Not verified: built image contents, external tool internals, live authentication/upload, historical CI, or operator-specific retention.
- Applicability: no HTTP controllers; no duplicate architecture overview; root policies and licence remain at repository root.
