# Error Handling

## Failure Taxonomy

| Failure Boundary | Local Handling | Consequence |
|---|---|---|
| Empty username | Fatal stdout message, exit one | No VDF/helper/client work |
| Empty password | Fatal stdout message, exit one | No VDF/helper/client work |
| VDF write failure | No status check or strict mode | Continues; client may see absent, partial, or old descriptor |
| VDF print failure | No status check | Continues without descriptor log |
| Helper nonzero | `run_steamcmd` returns one | Client skipped; generic retry |
| Helper zero with bad/empty stdout | No validation | Bad code reaches login |
| Client nonzero | Generic retry path | No distinction between authentication, validation, upload, or transport failure |
| Client/helper hangs | No timeout | Attempt blocks until external interruption |
| Missing terminal log files | `cat` reports errors | Explicit final exit remains two |
| Persistent failures | Broken counter normally remains one | Repeats until success/cancellation |

## Status Propagation

The function returns SteamCMD's status when it invokes the client. The loop immediately tests `$?`; all nonzero statuses are collapsed into the same action. A helper failure is collapsed to one rather than preserving its exact status. The final application status is zero on observed client success or two if the loop ends without success.

There is no `set -euo pipefail`, exception framework, trap, error object, rollback, cleanup hook, or remote reconciliation. Enabling strict mode mechanically could change intended status inspection and unset-variable behaviour; treat it as a tested control-flow change, not cosmetic style.

## Recovery

Check local credentials and path/metadata first. Diagnose helper and client output without exposing secrets. Stop indefinitely retrying jobs rather than assuming a three-attempt limit. Verify Workshop's actual state before rerunning after an ambiguous network failure, because a nonzero process status does not prove there was no publication.

The [retry flow](./flows/retries-and-exit-status.md) explains terminal diagnostic reachability. [Troubleshooting](./troubleshooting.md) maps symptoms to safe checks; [tests](./testing.md) separate verified local behaviour from untested integration assumptions.
