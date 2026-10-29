# Testing

## Repository Baseline

The reviewed tree has no automated test suite, test runner configuration, repository-owned CI workflow, or integration fixture. [CONTRIBUTING.md](../CONTRIBUTING.md) explicitly says no automated tests exist. The [root architecture](../ARCHITECTURE.md) describes Docker/workflow/manual verification, but no committed workflow demonstrates those claims.

A bare container run without credentials tests only early validation, not authentication or upload. Building the image verifies installation steps, not successful publication.

## Checks Performed For This Documentation

On 2026-10-29:
- `bash -n entrypoint.sh` passed syntax validation.
- A bounded harness used the actual loop text with mocked client and delay; persistent failure with `ATTEMPTS` unset reproduced the stuck-at-one counter.
- Two isolated checks verified missing username and missing password each exit one.
- In-memory command substitution mocks verified password-only success and seeded success each invoke the client once and exit zero.
- With inherited `ATTEMPTS=2`, a client failure reached status two after one call; helper failure reached status two without a client call.

Mocks replaced fixed executable paths, redirected the descriptor to `/dev/null`, suppressed `cat`, and bypassed delays. Thus these checks establish local branch/status behaviour only, not real VDF contents, files, executable availability, or remote effects. Harnesses were ephemeral; they are not committed regression tests.

No Docker build, real helper execution, Steam authentication, or upload was attempted. No secrets were required.

## Recommended Regression Matrix

| Area | Cases | Assertions |
|---|---|---|
| Credentials | Each missing, both missing, valid | Ordered message/status; no descriptor/client effect when invalid |
| Descriptor | Normal values, empty input, spaces, quotes/newlines, missing workspace | Exact fields; explicit policy for invalid VDF and unsafe paths |
| File failures | Unwritable target, missing content, old descriptor | Intended stop/continue behaviour; no accidental stale upload |
| Authentication | No seed, valid helper result, helper nonzero, empty helper output | Argument boundaries, client gating, status propagation |
| Retries | All fail, first succeeds, later succeeds | Exact call count, finite budget, delay policy, no extra publication after success |
| Ambient state | `ATTEMPTS` unset/set | Corrected code must not depend on unrelated environment |
| Diagnostics | Missing/large/sensitive logs | Final status, bounded output, redaction policy |
| Integration | Controlled account and disposable authorized item | Confirm actual item content, changenote, authorization, and final logs |

Do not use production credentials for mock tests. Isolate time and external processes, bound failing tests so the known loop cannot hang them, and test remote side effects only with explicit authorization. [Change guide](./change-guide.md) identifies the narrowest checks per modification.
