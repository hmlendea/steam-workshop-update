# Container Image

## Build Contract

The [Dockerfile](../../Dockerfile) starts from `cm2network/steamcmd:root`, installs `wget` using `apt-get`, cleans package lists, declares empty credential defaults, copies the [entrypoint](../../entrypoint.sh), and makes it executable. It downloads the Linux x64 `steam-totp` executable from the `hmlendea/steam-totp` release `v1.0.1`, installing it at `/home/steam/steam-totp`.

The final command is `ENTRYPOINT ["/entrypoint.sh"]`, with `CMD ["."]`. These compose into `/entrypoint.sh .`; the script ignores the argument. No published action image is named: [action metadata](../../action.yml) selects this Dockerfile for building by the runner.

## Dependency And Filesystem Assumptions

| Assumption | Why It Matters |
|---|---|
| Base supplies Bash and SteamCMD at `/home/steam/steamcmd/steamcmd.sh` | Entrypoint shebang and hardcoded client command |
| Base supports `apt-get` and required privileges | Package installation happens during build |
| Runtime can write `/home/steam` | Descriptor is written before upload |
| Base provides compatible Linux x64 runtime libraries | Downloaded helper has no alternative architecture selection |
| Certificate trust and outbound HTTPS work during build | Helper download and package retrieval |

No `USER`, `WORKDIR`, `HEALTHCHECK`, volume declaration, or image-level retry/timeout is added. The upstream tag is named `root`, but exact effective user and image contents require inspecting the resolved base; this repository does not pin its digest or explicitly select a final user.

## Reproducibility And Trust

The base tag and apt package versions float. The helper URL contains a version, but there is no checksum or signature verification step. Build output can vary as upstream dependencies change. The helper is downloaded even when callers never supply a seed.

## Failure And Verification

Chained build commands stop their layer when a command fails. That differs from the non-strict runtime script. A successful build demonstrates dependency acquisition and file installation, not successful authentication or publication.

No Docker build, base-image inspection, or helper execution was performed for this documentation task. See [deployment](../build-and-deployment.md), [dependencies](../dependencies.md), and [security boundaries](../security.md).
