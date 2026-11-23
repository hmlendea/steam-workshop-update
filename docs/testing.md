# Testing

## Repository Baseline

The repository ships one automated suite, [tests/test_entrypoint.sh](../tests/test_entrypoint.sh), plus an optional integration harness under `tests/integration/` that requires real Steam credentials and an authorized Workshop item. There is no test-enforcing CI workflow, so the suite is not enforced automatically; the only repository-owned workflow maintains the `latest` tag.

The unit suite sources the entrypoint's functions, extracts the real retry loop, and asserts validation, redaction, TOTP shape, strict-mode, exit-status, arg-array, and native-execution properties. Running it requires Bash only: no network, SteamCMD, or credentials.

A local container run without credentials tests only early validation, not authentication or upload. Building the local test image verifies installation steps, not successful publication.

## Checks Performed For This Documentation

On 2026-11-16:
- `bash -n entrypoint.sh` and `bash -n scripts/install-steamcmd.sh` passed syntax validation.
- `bash tests/test_entrypoint.sh` passed all 43 assertions, including the extracted retry loop producing exactly three attempts on persistent failure and one on immediate success.

The suite covers local control flow only; it does not observe real client statuses, VDF contents on disk, executable availability, or remote effects.

No Docker build, real helper execution, Steam authentication, or upload was attempted. No secrets were required.

## Recommended Regression Matrix

| Area | Cases | Assertions |
|---|---|---|
| Credentials | Each missing, both missing, valid | Ordered message/status; no descriptor/client effect when invalid |
| Descriptor | Normal values, empty input, spaces, quotes/newlines, missing workspace | Exact fields; explicit policy for invalid VDF and unsafe paths |
| File failures | Unwritable target, missing content, old descriptor | Intended stop/continue behaviour; no accidental stale upload |
| Authentication | No seed, valid helper result, helper nonzero, empty helper output | Argument boundaries, client gating, status propagation |
| Retries | All fail, first succeeds, later succeeds | Exact call count, finite budget, delay policy, no extra publication after success |
| Ambient state | `ATTEMPTS` set in the environment | Retry budget must not depend on unrelated environment |
| Diagnostics | Missing/large/sensitive logs | Final status, bounded output, redaction policy |
| Integration | Controlled account and disposable authorized item | Confirm actual item content, changenote, authorization, and final logs |

Do not use production credentials for mock tests. Isolate time and external processes, bound failing tests so the known loop cannot hang them, and test remote side effects only with explicit authorization. [Change guide](./change-guide.md) identifies the narrowest checks per modification.
