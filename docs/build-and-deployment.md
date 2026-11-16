# Build And Deployment

## Install Pipeline

[Action metadata](../action.yml) declares a composite action. The runner executes [scripts/install-steamcmd.sh](../scripts/install-steamcmd.sh), which ensures a 32-bit runtime, downloads Valve's SteamCMD archive, bootstraps the client, and downloads the `steam-totp` helper into `${STEAMCMD_ROOT}` (default `${RUNNER_TEMP}/steamcmd`). The second step runs [entrypoint.sh](../entrypoint.sh). There is no image build, artifact packaging, or repository-owned publish workflow.

Install requires access to the Steam CDN, GitHub Releases, and the runner's package manager when the 32-bit loader is missing. Runtime requires Steam access. No environment-specific deployment files, deployment database, readiness probe, or long-running server exist.

## Supported Topology And Constraints

The implementation targets a Linux runner and downloads a Linux x64 helper. Self-hosted execution additionally needs a writable temporary directory and, when absent, permission to install `lib32gcc-s1`/`glibc.i686`. The repository does not establish ARM compatibility, a tested OS matrix, or pinned transitive runtime versions.

The SteamCMD download URL is mutable and the helper has no integrity check. Do not assume a fixed client revision without inspecting the installed tree.

## Local Verification Levels

| Level | What It Establishes | What It Does Not |
|---|---|---|
| Bash syntax check | Scripts parse | Runtime tools or control-flow correctness |
| Unit suite | Validation, redaction, retry budget, argument shape | Steam login/upload |
| Installer run | Client and helper acquired | Correct action inputs or publication |
| Bare script run | Empty-credential validation | Correct action inputs or publication |
| Authorized integration run | Behaviour for one concrete environment/account/item | General service reliability or exactly-once publication |

Direct script use must explicitly supply `INPUT_*`, `GITHUB_WORKSPACE`, credentials, and a completed install. GitHub metadata defaults are not applied automatically.

## Caller Responsibilities

Choose an action ref, prepare content, bind secrets, set a job timeout, and serialize updates per item. Review mutable download dependencies separately even if pinning the action source. Persistent failure now stops after three attempts ([retry policy](./flows/retries-and-exit-status.md)).

The [root architecture](../ARCHITECTURE.md) remains the overview; [runner internals](./components/runner-environment.md) and [dependencies](./dependencies.md) specify the install contracts. No deployment or integration run was performed during documentation generation.
