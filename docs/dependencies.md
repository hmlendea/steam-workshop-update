# Dependencies

## Build And Runtime Dependencies

| Dependency | Source/Version Selection | Use And Failure Impact |
|---|---|---|
| GitHub Actions composite action support | Calling runner | Supplies input environment, workspace context, and process result collection |
| Linux runner | Caller infrastructure | The installer fails fast on other operating systems |
| 32-bit glibc runtime | Present on GitHub-hosted runners; added as `lib32gcc-s1`/`glibc.i686` when missing | The SteamCMD client is i386; without it the client cannot start |
| SteamCMD client | `steamcmd_linux.tar.gz` from the Steam CDN, unpinned | Downloaded and bootstrapped at install time |
| `steam-totp` | GitHub release `v1.0.1`, asset `steam-totp_1.0.1_linux-x64` | Downloaded at install time, executed only with seed |
| Bash and basic utilities | Runner image | Conditions, arithmetic, heredoc, `cat`, `tar`, `sleep`; absent tools break orchestration |
| Steam services | External Valve infrastructure | Authentication and Workshop publication; no local substitute in production |

The client's exact revision, transitive libraries, and the helper's runtime requirements are not fixed by repository source. There are no repository package manifests, lockfiles, vendored tool sources, or checksum manifests.

## Dependency Direction

[Action metadata](../action.yml) declares a composite action; the first step installs the client and helper through [scripts/install-steamcmd.sh](../scripts/install-steamcmd.sh); the second step runs the [entrypoint](../entrypoint.sh), which invokes the helper and client; the client communicates with Valve. Neither funding metadata nor root policy documents participates in runtime configuration.

## Upgrade Checklist

Review runner operating-system compatibility, 32-bit library availability, helper architecture, authentication argument shape, client status semantics, and security provenance. A successful install does not test login or upload. Start with [mocked orchestration scenarios](./testing.md), then use a controlled integration target if authorized.

See [build details](./build-and-deployment.md) and [external integration boundaries](./integrations.md).
