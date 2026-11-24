# Configuration

## Action Inputs

[Action metadata](../action.yml) declares these strings and maps them to their `INPUT_*` counterparts inside the composite steps. The [entrypoint](../entrypoint.sh) reads the environment, not positional arguments.

| Workflow Input | Environment Consumer | Required In Metadata | Default | Transformation |
|---|---|---|---|---|
| `appid` | `INPUT_APPID` | Yes | None | Inserted as VDF `appid` |
| `itemid` | `INPUT_ITEMID` | Yes | None | Inserted as VDF `publishedfileid` |
| `path` | `INPUT_PATH` | Yes | None | Literal `${GITHUB_WORKSPACE}/${INPUT_PATH}` becomes `contentfolder` |
| `changenote` | `INPUT_CHANGENOTE` | No | Attribution below | Inserted as VDF `changenote` |
| `icon` | `INPUT_ICON` | No | Auto-detected | Literal `${GITHUB_WORKSPACE}/${INPUT_ICON}` becomes VDF `previewfile`; when omitted, the content directory is probed for a recognised filename, and `previewfile` is omitted entirely when none applies. A resolved image is downscaled to fit within 512 pixels in either dimension before the descriptor is written. |

Exact metadata default:

```text
Uploaded using the [url=https://github.com/hmlendea/steam-workshop-update]hmlendea/steam-workshop-update[/url] GitHub Actions workflow.
```

The script validates that `INPUT_APPID` and `INPUT_ITEMID` are numeric, that `${GITHUB_WORKSPACE}/${INPUT_PATH}` exists and resolves inside the workspace, that `INPUT_CHANGENOTE` is printable and at most 1000 characters, and that an explicitly supplied `INPUT_ICON` names an existing file inside the workspace. It does not escape VDF strings or apply the metadata default itself; a direct script invocation bypasses metadata defaults. Preview detection does not depend on metadata and therefore also applies to direct invocation. Absolute paths are not treated as replacements for the workspace prefix, though `realpath` containment rejects traversal outside the workspace.

A resolved preview image is checked with ImageMagick and, when either dimension exceeds `PREVIEW_MAX_DIMENSION` (512), downscaled into a new file at `${STEAMCMD_ROOT}/preview.<extension>`, which becomes the descriptor's `previewfile`. The original workspace file is never modified, the aspect ratio is preserved, and smaller images are never enlarged. An unreadable image or absent ImageMagick aborts the run with status one rather than emitting an oversized preview.

## Credentials And Runtime Environment

| Variable | Source | Behaviour |
|---|---|---|
| `STEAM_USERNAME` | Caller environment, normally GitHub secret | Empty/unset exits one before file creation |
| `STEAM_PASSWORD` | Caller environment, normally GitHub secret | Empty/unset exits one after username check |
| `STEAM_2FASEED` | Optional caller secret | Empty skips helper; nonempty invokes helper on every attempt |
| `GITHUB_WORKSPACE` | Runner, or explicit local setup | Prefix for content path; the resolved path must stay inside it |
| `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT` | Exported as `1` in seeded branch | Inherited by helper and subsequent child processes |
| `STEAMCMD_ROOT` | Optional override, default `${RUNNER_TEMP}/steamcmd` | Client installation, descriptor, and helper location |
| `STEAMCMD_HOME` | Optional override, default `${STEAMCMD_ROOT}/home` | Steam session home and log directory |

Credentials must be supplied through the calling step's `env`, because composite actions do not forward caller environment implicitly to inner steps. There is no configuration file, CLI parser, secret-store integration, or precedence merge implemented in the script.

## Fixed Values

The VDF lives at `${STEAMCMD_ROOT}/workshop.vdf`; SteamCMD at `${STEAMCMD_ROOT}/install/steamcmd.sh`; the helper at `${STEAMCMD_ROOT}/steam-totp`. `ATTEMPTS_MAX=3`, a two-second post-failure delay, and `PREVIEW_MAX_DIMENSION=512` are hardcoded, and a downscaled preview is written to `${STEAMCMD_ROOT}/preview.<extension>`. These are not action inputs.

Changes to any interface value require synchronized review of [metadata](../action.yml), [orchestration](../entrypoint.sh), [workflow examples](./api-usage-examples.md), and [contracts](./invariants.md).
