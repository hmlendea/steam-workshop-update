# Configuration

## Action Inputs

[Action metadata](../action.yml) declares these strings; GitHub Actions supplies their `INPUT_*` counterparts to the Docker action. The [entrypoint](../entrypoint.sh) reads the environment, not positional arguments.

| Workflow Input | Environment Consumer | Required In Metadata | Default | Transformation |
|---|---|---|---|---|
| `appid` | `INPUT_APPID` | Yes | None | Inserted as VDF `appid` |
| `itemid` | `INPUT_ITEMID` | Yes | None | Inserted as VDF `publishedfileid` |
| `path` | `INPUT_PATH` | Yes | None | Literal `${GITHUB_WORKSPACE}/${INPUT_PATH}` becomes `contentfolder` |
| `changenote` | `INPUT_CHANGENOTE` | No | Attribution below | Inserted as VDF `changenote` |

Exact metadata default:

```text
Uploaded using the [url=https://github.com/hmlendea/steam-workshop-update]hmlendea/steam-workshop-update[/url] GitHub Actions workflow.
```

The script does not validate any `INPUT_*` value, check directory existence, verify numeric IDs, escape VDF strings, or apply the metadata default itself. A direct Docker invocation bypasses metadata defaults. Absolute paths are not treated as replacements for the workspace prefix; traversal components are not rejected.

## Credentials And Runtime Environment

| Variable | Source | Behaviour |
|---|---|---|
| `STEAM_USERNAME` | Caller environment, normally GitHub secret | Empty/unset exits one before file creation |
| `STEAM_PASSWORD` | Caller environment, normally GitHub secret | Empty/unset exits one after username check |
| `STEAM_2FASEED` | Optional caller secret | Empty skips helper; nonempty invokes helper on every attempt |
| `GITHUB_WORKSPACE` | Runner, or explicit local setup | Prefix for content path; no validation |
| `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT` | Exported as `1` in seeded branch | Inherited by helper and subsequent child processes |
| `ATTEMPTS` | Not a documented input | Accidentally influences retry counter; must not be treated as supported configuration |

The [image](../Dockerfile) initializes all three credential variables to empty values. Caller environment values must replace these for an actual upload. There is no configuration file, CLI parser, secret-store integration, or precedence merge implemented in the script.

## Fixed Values

The VDF lives at `/home/steam/workshop.vdf`; SteamCMD at `/home/steam/steamcmd/steamcmd.sh`; the helper at `/home/steam/steam-totp`. `ATTEMPTS_MAX=3` and a two-second post-failure delay are hardcoded. These are not action inputs. The default container argument `.` is ignored by the script.

Changes to any interface value require synchronized review of [metadata](../action.yml), [orchestration](../entrypoint.sh), [workflow examples](./api-usage-examples.md), and [contracts](./invariants.md).
