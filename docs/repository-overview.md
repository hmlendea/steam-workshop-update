# Repository Overview

## Purpose And Scope

This repository implements a Docker-based GitHub Action that asks Valve's SteamCMD client to update a Steam Workshop item. The workflow author owns content preparation, Steam account access, app/item selection, and invocation timing. The action owns environment checks, VDF generation, optional local two-factor code generation, and repeated SteamCMD invocation.

It is a short-lived command orchestrator, not a web service, persistent daemon, content builder, or direct implementation of Valve's network protocol. The public interface is [action metadata](../action.yml), credentials supplied through the environment, and the container process exit status. There are no action outputs or HTTP controllers.

## Execution Ownership

| Boundary | Producer | Consumer | Contract |
|---|---|---|---|
| Workflow to action | Calling workflow | GitHub Actions Docker action runner | Four `with` inputs; three credential environment variables |
| Runner to script | GitHub Actions | [Entrypoint](../entrypoint.sh) | `INPUT_*`, `GITHUB_WORKSPACE`, credential environment; mounted content |
| Script to client | `run_steamcmd` | SteamCMD | Login arguments and fixed VDF pathname |
| Script to helper | `run_steamcmd` | Downloaded `steam-totp` executable | Seed argument; stdout becomes code; status determines whether login runs |
| Client to Valve | SteamCMD | Steam services | External authentication/upload protocol; implementation not in this repository |
| Script to runner | Entrypoint process | Calling job | stdout/stderr and exit status; no structured result |

## Principal Sources

Read the [implementation map](./repository-structure.md), [upload flow](./flows/workshop-update.md), and [invariants](./invariants.md) before changing behaviour. The [root architecture](../ARCHITECTURE.md) supplies the original overview; [evidence discrepancies](./ambiguities-and-open-questions.md) distinguish that overview's claims from current execution.

## Critical Current Behaviour

The intended three-attempt limit is not enforced in an ordinary environment: `ATTEMPTS_CURRENT=$((ATTEMPTS+1))` reads `ATTEMPTS`, not the current counter. With `ATTEMPTS` unset, failures leave the counter at one indefinitely. Success still exits zero. See [retry analysis](./flows/retries-and-exit-status.md).

Reviewed against repository sources on 2026-10-29. External binary internals and a live Workshop update were not verified.
