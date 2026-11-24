# Quick Start

## Read Before Publishing

Start with the [repository overview](./repository-overview.md), [input schema](./configuration.md), and [workflow example](./api-usage-examples.md). Failures stop after three attempts, but a hung client can still stall a job, so configure an external job timeout and read [retry analysis](./flows/retries-and-exit-status.md).

## Prepare A Calling Workflow

1. Use a Linux runner. GitHub-hosted runners already provide the 32-bit runtime the client needs.
2. Check out or otherwise create the upload content in the workflow workspace. The action does not perform checkout or build content.
3. Identify the Steam app and existing Workshop item; confirm the chosen Steam account can update it.
4. Store username/password as protected workflow secrets. Supply the optional seed only after verifying its format is compatible with the helper; the existing [README](../README.md) specifies a standard TOTP seed.
5. Invoke the action with a reviewed ref, app ID, item ID, and relative content path. Optionally provide a changenote and a preview image; otherwise a recognised preview filename in the content directory is used automatically.
6. Add caller-level timeout and same-item serialization. Inspect logs carefully and confirm remote publication for initial integration.

The [example page](./api-usage-examples.md) is a step fragment, not a complete workflow. Never test by publishing to an item without permission.

## Local Orientation Without Credentials

The production files are [metadata](../action.yml), the [installer](../scripts/install-steamcmd.sh), and the [script](../entrypoint.sh). Bash syntax validation and the unit suite can verify local control flow without network access. See [testing](./testing.md) for observed checks and recommended cases.

A bare script run exits one because credentials are unset, and a run without an installed client also exits one. Neither is proof of a working Workshop upload.

## Next Reading

Use [upload flow](./flows/workshop-update.md) to understand execution, [troubleshooting](./troubleshooting.md) for failures, and [change guide](./change-guide.md) before editing. [Security policy](../SECURITY.md), [privacy policy](../PRIVACY.md), and [licence](../LICENSE) remain root documents.
