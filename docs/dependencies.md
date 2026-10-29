# Dependencies

## Build And Runtime Dependencies

| Dependency | Source/Version Selection | Use And Failure Impact |
|---|---|---|
| GitHub Actions Docker action support | Calling runner | Builds image, supplies input environment, mounts workspace, captures process result |
| Docker-compatible Linux execution | Caller infrastructure | Container launch; absent support prevents entrypoint execution |
| SteamCMD base image | `cm2network/steamcmd:root` in [Dockerfile](../Dockerfile) | Provides client and underlying runtime; tag is not digest-pinned |
| APT repositories and `wget` | Unpinned apt installation | Build-time package acquisition and helper download |
| `steam-totp` | GitHub release `v1.0.1`, asset `steam-totp_1.0.1_linux-x64` | Installed at build time, executed only with seed |
| Bash and basic utilities | Base image | Conditions, arithmetic, heredoc, `cat`, `sleep`; absent tools break orchestration |
| Steam services | External Valve infrastructure | Authentication and Workshop publication; no local substitute in production |

The base's exact operating system, library versions, SteamCMD revision, final user, and transitive package inventory are not fixed by repository source alone. The downloaded helper's runtime requirements were not inspected. There are no repository package manifests, lockfiles, vendored tool sources, or checksum manifests.

## Dependency Direction

[Action metadata](../action.yml) selects the image build; the image installs the script and helper; the script invokes the helper/client; the client communicates with Valve. Neither funding metadata nor root policy documents participates in runtime configuration.

## Upgrade Checklist

Review base compatibility, fixed executable paths, helper architecture, authentication argument shape, client status semantics, and security provenance. A successful Docker build alone does not test login or upload. Start with [mocked orchestration scenarios](./testing.md), then use a controlled integration target if authorized.

See [build details](./build-and-deployment.md) and [external integration boundaries](./integrations.md).
