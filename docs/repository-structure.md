# Repository Structure

## Implementation Map

| Location | Ownership And Consumers | Change Implications |
|---|---|---|
| [action.yml](../action.yml) | Action identity, composite steps, five user inputs, `INPUT_*` mapping, changenote default | Input changes propagate into entrypoint variables, examples, and configuration docs |
| [scripts/install-steamcmd.sh](../scripts/install-steamcmd.sh) | 32-bit runtime check, SteamCMD download/bootstrap, helper download, `GITHUB_ENV` export | Client revision, download sources, architecture, and permissions |
| [Dockerfile](../Dockerfile) | Local test image only; not used by GitHub Actions | Mirrors the installer for local verification |
| [entrypoint.sh](../entrypoint.sh) | Credential checks, input validation, VDF heredoc, `run_steamcmd`, retry loop, exit/reporting paths | All production orchestration behaviour |
| [tests/test_entrypoint.sh](../tests/test_entrypoint.sh) | Unit suite over extracted functions and the real retry loop | Retry, validation, redaction, and layout regressions |
| [tests/integration/](../tests/integration/) | Optional live-credential integration harness | Manual end-to-end verification |
| [.github/FUNDING.yml](../.github/FUNDING.yml) | Funding metadata | Not loaded by the action; no upload effect |
| [.github/workflows/release-latest-tag.yml](../.github/workflows/release-latest-tag.yml) | Force-moves the `latest` tag onto each published release | No effect on the action runtime; controls the mutable `@latest` reference |
| [README.md](../README.md) | Existing user introduction and workflow example | Documents intended retry and runner behaviour |
| [ARCHITECTURE.md](../ARCHITECTURE.md) | Existing architectural overview | Contains claims that require qualification; see [open questions](./ambiguities-and-open-questions.md) |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | Contribution process and suggested checks | Production scripts enable `set -euo pipefail` |
| [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md) | Community conduct | No runtime consumer |
| [SECURITY.md](../SECURITY.md) | Security reporting and support policy | Separate from implementation threat analysis |
| [PRIVACY.md](../PRIVACY.md) | Published data-handling policy | Not a substitute for examining external client data and host retention |
| [LICENSE](../LICENSE) | GPL version 3 licence text | Governs distribution; not runtime configuration |
| [Documentation index](./INDEX.md) | Evidence-based operational and modification knowledge | Update alongside affected implementation |

## Source Anchors

There is one function relevant to upload in the [entrypoint](../entrypoint.sh), `run_steamcmd`, alongside helpers `sanitize_output`, `log_sanitized_cmd`, `validate_input`, `resolve_preview_file`, `resolve_image_tooling`, and `downscale_preview_file`. The remainder executes at script top level, in this order:
1. Path and layout resolution.
2. Username, password, and client-availability checks.
3. Input validation, explicit icon validation, and content-path containment.
4. Preview-image resolution and optional downscaling.
5. VDF generation and printing.
6. Function definitions.
7. Counter initialisation and upload loop.
8. Success exit or terminal diagnostics and failure exit.

[scripts/install-steamcmd.sh](../scripts/install-steamcmd.sh) owns client acquisition and exposes a `main` guard so its functions can be sourced. There are no namespaces, application packages, controllers, migrations, dependency lockfiles, or test-enforcing CI workflow files in the reviewed tracked tree.

## Documentation Layout

Collections separate [components](./components/entrypoint.md), [execution flows](./flows/workshop-update.md), [user behaviour](./behaviour/workshop-updates.md), and [interface applicability](./api-reference/INDEX.md). There is deliberately no second architecture overview: the existing [root document](../ARCHITECTURE.md) remains the architecture entry point, complemented by implementation-specific pages.
