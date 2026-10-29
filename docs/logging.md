# Logging

## Framework And Destinations

There is no logging library or configuration file. The [entrypoint](../entrypoint.sh) uses Bash `echo` and `cat`; helper and SteamCMD stdout/stderr are inherited. GitHub Actions captures process output as job logs. SteamCMD is also expected to produce files under `/home/steam/Steam/logs/`; exact external-client logging behaviour was not inspected.

## Messages And Levels

| Output | Timing | Semantics |
|---|---|---|
| `FATAL: Environment variable ...` | Missing username/password | Plain stdout prefix, not a structured fatal level |
| Complete VDF | Before first attempt | Includes IDs, content path, changenote |
| `Attempt N of 3...` | Before helper/client invocation | Progress; numbering becomes misleading after failures |
| `Attempt N failed. Retrying...` | After nonzero result | Generic failure; no status code or category recorded |
| `All 3 attempts failed.` | Terminal loop failure | Normally unreachable with unset `ATTEMPTS` and persistent failure |
| `stderr.txt`, `workshop_log.txt` contents | Terminal failure block | Entire file content, not filtered excerpts |
| External tool text | During invocation | Client/helper-specific, no wrapper normalization |

No Debug/Info/Warning/Error threshold exists. No level can be changed at runtime. External binaries may have their own settings, but none are configured here.

## Structure And Correlation

No standard timestamp, account field, item field, correlation ID, trace ID, or span ID is attached to each entry. The printed descriptor gives context once; GitHub workflow/job/step context provides platform-level association, not an application trace protocol. There is no request object or distributed tracing integration.

## Redaction And Audit

The script never deliberately echoes password or seed, but does not implement masking. They appear in child-process arguments, and the seed remains inherited environment. Generated codes are not registered for GitHub masking. Descriptor input may itself contain sensitive text, and external logs may contain account/session information. GitHub secret masking is platform behaviour, not proof that all derived or transformed values are hidden.

There is no separate audit sink or security-event schema. Authentication/upload output is ordinary job output. Do not enable shell tracing with production credentials or publish raw client logs.

## Retention And Performance

No rotation, archiving, deletion, retention period, sampling, rate limit, asynchronous queue, or buffering policy is implemented. Host/platform settings govern retained workflow logs; container/client lifecycle governs local files. Repeated failures can generate unbounded job output because of the [retry defect](./flows/retries-and-exit-status.md).

Output is synchronous from the wrapper's perspective. Printing a large descriptor or full client logs adds I/O and disclosure surface; no throughput benchmarks exist. There is no exception framework, stack-trace formatter, or inner-exception handling: process text and statuses are the only diagnostics.

See [troubleshooting](./troubleshooting.md), [state lifecycle](./state-and-persistence.md), and [root privacy policy](../PRIVACY.md).
