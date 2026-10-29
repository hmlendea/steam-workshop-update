# Data Model

## Workshop Descriptor

The [entrypoint](../entrypoint.sh) produces a single VDF document before attempting authentication:

```text
"workshopitem"
{
  "appid" "${INPUT_APPID}"
  "contentfolder" "${GITHUB_WORKSPACE}/${INPUT_PATH}"
  "changenote" "${INPUT_CHANGENOTE}"
  "publishedfileid" "${INPUT_ITEMID}"
}
```

This is a schematic showing variable positions, not literal generated content. Bash expands the unquoted heredoc. Values are inserted directly; input text is not recursively executed as shell code, but embedded quotes, backslashes, or newlines may change VDF interpretation. No VDF parser or schema validator runs locally.

| Field | Meaning | Consumer Assumption |
|---|---|---|
| `appid` | Target Steam application | SteamCMD accepts it and account can publish for it |
| `publishedfileid` | Existing Workshop item to update | Item exists and account has suitable rights |
| `contentfolder` | Absolute-looking workspace-prefixed folder | Mounted folder exists and contains complete upload content |
| `changenote` | Update text, including optional Workshop markup | Literal VDF insertion remains valid |

These assumptions are delegated, not checked. No entity database or relationship resolver ensures that the app, account, and item match.

## Other Data

Credentials remain script environment values and child-process arguments; the descriptor intentionally has no credential field. `STEAM_2FACODE` captures helper stdout without trailing newlines and is reused only for its associated client invocation. The script does not validate its length or format.

`ATTEMPTS_CURRENT`, `ATTEMPTS_MAX`, and `IS_SUCCESSFUL` are shell state, not persisted records. SteamCMD stdout, stderr, sessions, and files belong to the external client's contract; they are not parsed into domain objects.

## Result Model

There is no response body, uploaded-item output, digest, or published revision record. Success means SteamCMD returned zero. The script does not independently query Workshop to confirm publication or inspect the uploaded content. See [state](./state-and-persistence.md) and [failure semantics](./error-handling.md).
