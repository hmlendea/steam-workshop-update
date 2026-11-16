# Runner Environment

## Execution Contract

[Action metadata](../../action.yml) declares a composite action, so the runner executes the steps directly on its own operating system instead of inside a container:

1. [scripts/install-steamcmd.sh](../../scripts/install-steamcmd.sh) installs Valve's official SteamCMD client and the `steam-totp` helper under `${STEAMCMD_ROOT}`, which defaults to `${RUNNER_TEMP}/steamcmd`.
2. [entrypoint.sh](../../entrypoint.sh) validates inputs, writes the VDF descriptor, and invokes the client.

Composite actions do not populate `INPUT_*` variables automatically, so [metadata](../../action.yml) maps each `inputs.*` value explicitly.

## Why The Client Runs Natively

Earlier revisions built a Docker action from `cm2network/steamcmd:root`. That fails on GitHub's Ubuntu 26.04 runner image, which the `ubuntu-latest` label targets from November 2026: the image ships Docker 29.4.2, whose default seccomp profile denies `socketcall(2)`. The SteamCMD client is a 32-bit i386 binary and i386 glibc resolves names through `socketcall(2)`, so the client cannot reach Steam and reports `Steamcmd needs to be online to update`. The seccomp profile belongs to the runner's Docker daemon, and Docker actions expose no `--security-opt` override. Executing the client on the runner removes the container and its profile from the path.

## Dependency And Filesystem Assumptions

| Assumption | Why It Matters |
|---|---|
| A 32-bit loader exists (`/lib/ld-linux.so.2` or equivalent) | SteamCMD's client is i386; the installer adds `lib32gcc-s1` through `apt-get`, or `glibc.i686` through `dnf`, when it is absent |
| Bash, `tar`, and either `curl` or `wget` are available | Installer download and extraction |
| The runtime user can install packages | Only needed when the loader is missing; GitHub-hosted runners already satisfy it |
| `${STEAMCMD_ROOT}` is writable | Client installation, descriptor, and Steam session home |
| Outbound HTTPS reaches the Steam CDN, GitHub Releases, and Valve services | Installer bootstrap, helper download, and upload |

The installer fails fast on non-Linux runners. No `RUNNER_TOOL_CACHE` entry, checksum, or signature verification is added, and no `steamcmd` session state cleanup runs after a failed step.

## Local Test Image

[Dockerfile](../../Dockerfile) is retained for local verification only. It starts from `ubuntu:24.04`, installs `ca-certificates`, `curl`, `tar`, and `lib32gcc-s1`, copies the installer and entrypoint, and runs the installer at build time. GitHub Actions does not use it and no image is published.

## Reproducibility And Trust

The SteamCMD download URL is mutable and always resolves to the current client; no version, checksum, or digest is pinned. The helper URL contains a version (`v1.0.1`) but has no integrity verification. Install output can vary as upstream artefacts change.

## Failure And Verification

The installer fails its step when a download, extraction, or client bootstrap fails. Bootstrap is attempted three times because the first run replaces the client and can exit non-zero. A successful install demonstrates dependency acquisition only, not authentication or publication.

See [deployment](../build-and-deployment.md), [dependencies](../dependencies.md), and [security boundaries](../security.md).
