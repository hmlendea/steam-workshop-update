# Change Guide

## Impact Map

| Intended Change | Owning Sources | Required Contract Review | Focused Validation |
|---|---|---|---|
| Add/rename input | [Metadata](../action.yml), [script](../entrypoint.sh) | `INPUT_*` consumption, defaults, direct script callers | Metadata-to-environment mapping and exact VDF output |
| Change descriptor | [Script](../entrypoint.sh) | Quoting, path containment, client parser, printed data | Normal/hostile strings, write failure, stale-file handling |
| Fix retries | [Script](../entrypoint.sh) | Total attempts versus retries, terminal diagnostics | Exact counts for all-fail/eventual-success/helper-fail via [tests/test_entrypoint.sh](../tests/test_entrypoint.sh) |
| Change authentication | [Script](../entrypoint.sh) | Seed format, code capture, argument boundaries, inherited secrets | Mock both branches and helper failures before live login |
| Upgrade dependencies | [Installer](../scripts/install-steamcmd.sh) | Architecture, 32-bit runtime, download sources, provenance | Installer run plus focused mocked and authorized integration checks |
| Add outputs | [Metadata](../action.yml), [script](../entrypoint.sh) | Output schema and source of truth for remote publication | Consumer compatibility; no invented publication confirmation |
| Change logs | [Script](../entrypoint.sh) | Data disclosure, diagnostic reachability, volume, exit status | Missing/sensitive logs and failure-path checks |

## Safe Sequence

1. Read the owning [component](./components/entrypoint.md), relevant [flow](./flows/workshop-update.md), and [invariants](./invariants.md).
2. Establish the current focused baseline; preserve unrelated work.
3. Add or run deterministic, bounded tests before a behaviour change.
4. Make the smallest change that addresses the chosen contract.
5. Validate locally before authorizing any external publication.
6. Synchronize affected documentation and explicitly remove resolved caveats only when tested.

Do not add shell strict mode mechanically: existing `$?` handling, unvalidated variables, and retry behaviour need redesign/testing together. Do not treat ordinary retry success as proof of exactly-once remote effects.

## Documentation Dependencies

Input changes affect [configuration](./configuration.md), [data model](./data-model.md), and [examples](./api-usage-examples.md). Retry changes affect [retry flow](./flows/retries-and-exit-status.md), [errors](./error-handling.md), [testing](./testing.md), [FAQ](./faq.md), and [open questions](./ambiguities-and-open-questions.md). Security/logging changes require assessing root policy accuracy without duplicating those policies under this directory.

See [maintenance](./documentation-maintenance.md) for source-of-truth and review metadata rules.
