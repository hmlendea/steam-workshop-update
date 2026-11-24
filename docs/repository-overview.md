# Repository Overview

## Purpose And Scope

This repository implements a composite GitHub Action that asks Valve's SteamCMD client to update a Steam Workshop item. The workflow author owns content preparation, Steam account access, app/item selection, and invocation timing. The action owns environment checks, client installation, VDF generation, optional local two-factor code generation, and repeated SteamCMD invocation.

It is a short-lived command orchestrator, not a web service, persistent daemon, content builder, or direct implementation of Valve's network protocol. The public interface is [action metadata](../action.yml), credentials supplied through the step environment, and the action's process exit status. There are no action outputs or HTTP controllers.

## Execution Ownership

| Boundary | Producer | Consumer | Contract |
|---|---|---|---|
| Workflow to action | Calling workflow | GitHub Actions composite action runner | Five `with` inputs; three credential environment variables |
| Install step to stopped step | [Installer](../scripts/install-steamcmd.sh) | [Entrypoint](../entrypoint.sh) | Client at `${STEAMCMD_ROOT}/install/steamcmd.sh`; helper at `${STEAMCMD_ROOT}/steam-totp` |
| Runner to script | GitHub Actions | [Entrypoint](../entrypoint.sh) | `INPUT_*`, `GITHUB_WORKSPACE`, credential environment; workspace content |
| Script to client | `run_steamcmd` | SteamCMD | Login arguments and VDF pathname |
| Script to helper | `run_steamcmd` | Downloaded `steam-totp` executable | Seed argument; stdout becomes code; status determines whether login runs |
| Client to Valve | SteamCMD | Steam services | External authentication/upload protocol; implementation not in this repository |
| Script to runner | Entrypoint process | Calling job | stdout/stderr and exit status; no structured result |

## Principal Sources

Read the [implementation map](./repository-structure.md), [upload flow](./flows/workshop-update.md), and [invariants](./invariants.md) before changing behaviour. The [root architecture](../ARCHITECTURE.md) supplies the overview; [evidence discrepancies](./ambiguities-and-open-questions.md) distinguish that overview's claims from current execution.

## Critical Current Behaviour

Failures stop after three attempts because the loop counter is incremented correctly, the client command is tested as an `if` condition under `set -euo pipefail`, and [tests/test_entrypoint.sh](../tests/test_entrypoint.sh) asserts both the three-attempt budget and immediate success. The action runs natively rather than in a container, which is what allows the 32-bit client to reach Steam on GitHub's Ubuntu 26.04 runners. See [runner environment](./components/runner-environment.md).

Reviewed against repository sources on 2026-11-16. External binary internals and a live Workshop update were not verified.
