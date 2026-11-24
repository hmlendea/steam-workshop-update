# Troubleshooting

| Symptom | Causal Explanation | Safe Next Check |
|---|---|---|
| Fatal missing username/password | Empty or unbound environment | Confirm secret binding names without printing values |
| `Steamcmd needs to be online to update` | Client cannot reach Steam, historically Docker 29.4.2's seccomp deny of `socketcall(2)` for the i386 client | Confirm the action revision is one that runs natively; see [runner environment](./components/runner-environment.md) |
| `FATAL: SteamCMD was not found` | Installer step skipped or failed | Confirm the install step succeeded and `${STEAMCMD_ROOT}` is writable |
| Installer fails adding 32-bit runtime | No loader and no permitted package install | Preinstall `lib32gcc-s1`/`glibc.i686` on self-hosted runners |
| Job prints `Attempt 3 of 3...` then fails | Three attempts exhausted | Inspect the dumped Steam logs and the [retry policy](./flows/retries-and-exit-status.md) |
| Helper failure before any login | Seed branch returns one on helper nonzero or malformed code | Verify installed helper compatibility and redacted stderr |
| Login fails despite helper zero | Account/challenge/time conditions external | Check clock and authorized helper/account setup; never share seed/code |
| Invalid descriptor/client parse error | Unescaped quotes/newlines in changenote | Review sanitized generated VDF against [schema](./data-model.md) |
| `FATAL: ImageMagick is required` | Preview image resolved but neither `magick` nor `convert`/`identify` is installed | Install ImageMagick on self-hosted runners, or remove the preview image |
| `FATAL: Unable to read the dimensions` | The resolved preview file is not a decodable image | Verify the preview file opens as an image, or remove it |
| `FATAL: Input path ...` | Content path missing or outside the workspace | Confirm the workspace checkout and relative directory |
| Upload permission failure | App/item/account assumptions delegated to Steam | Verify target ownership and authorization outside action |
| Install fails fetching client/helper | Install-time network or provenance dependency | Inspect the download URL, CDN access, and GitHub Releases access |
| Local Docker run immediately exits one | No credentials supplied | Treat as validation smoke check, not failed upload integration |
| Step succeeds but remote state is unexpected | Success is client zero status only | Independently inspect intended Workshop item/content |

## Diagnostic Hygiene

Do not enable shell tracing or print environment variables with live credentials. The generated descriptor and external logs may contain sensitive user-supplied content or session information. Redact before sharing, and follow the [security reporting policy](../SECURITY.md) for suspected vulnerabilities.

Verify remote state before rerunning an ambiguous failed upload. A local failure may follow a remote side effect, and no rollback or idempotency mechanism exists. Use [error semantics](./error-handling.md), [logging behaviour](./logging.md), and [authentication flow](./flows/authentication.md) to narrow the cause rather than changing all configuration at once.
