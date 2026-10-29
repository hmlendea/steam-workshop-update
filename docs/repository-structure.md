# Repository Structure

## Implementation Map

| Location | Ownership And Consumers | Change Implications |
|---|---|---|
| [action.yml](../action.yml) | Action identity, Docker binding, four user inputs, changenote default | Input changes propagate into entrypoint variables, examples, and configuration docs |
| [Dockerfile](../Dockerfile) | SteamCMD base image, `wget`, helper download, executable installation, launch configuration | Paths, runtime libraries, architecture, permissions, and network supply chain |
| [entrypoint.sh](../entrypoint.sh) | Credential checks, VDF heredoc, `run_steamcmd`, retry loop, exit/reporting paths | All production orchestration behaviour |
| [.github/FUNDING.yml](../.github/FUNDING.yml) | Funding metadata | Not loaded by the action; no upload effect |
| [README.md](../README.md) | Existing user introduction and workflow example | Contains intended retry behaviour, not evidence of a working retry cap |
| [ARCHITECTURE.md](../ARCHITECTURE.md) | Existing architectural overview | Contains claims that require qualification; see [open questions](./ambiguities-and-open-questions.md) |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | Contribution process and suggested checks | Suggested shell strict mode is not enabled in production |
| [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md) | Community conduct | No runtime consumer |
| [SECURITY.md](../SECURITY.md) | Security reporting and support policy | Separate from implementation threat analysis |
| [PRIVACY.md](../PRIVACY.md) | Published data-handling policy | Not a substitute for examining external client data and host retention |
| [LICENSE](../LICENSE) | GPL version 3 licence text | Governs distribution; not runtime configuration |
| [Documentation index](./INDEX.md) | Evidence-based operational and modification knowledge | Update alongside affected implementation |

## Source Anchors

There is one shell function, `run_steamcmd`, in the [entrypoint](../entrypoint.sh). The remainder executes at script top level, in this order:
1. Username then password nonempty checks.
2. VDF generation and printing.
3. Function definition.
4. Counter initialisation and upload loop.
5. Success exit or terminal diagnostics and failure exit.

There are no namespaces, application packages, controllers, migrations, test directories, dependency lockfiles, or repository-owned CI workflow files in the reviewed tracked tree. Do not invent service layers or tests from the root prose.

## Documentation Layout

Collections separate [components](./components/entrypoint.md), [execution flows](./flows/workshop-update.md), [user behaviour](./behaviour/workshop-updates.md), and [interface applicability](./api-reference/INDEX.md). There is deliberately no second architecture overview: the existing [root document](../ARCHITECTURE.md) remains the architecture entry point, complemented by implementation-specific pages.
