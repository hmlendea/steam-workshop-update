# Quick Start

## Read Before Publishing

Start with the [repository overview](./repository-overview.md), [input schema](./configuration.md), and [workflow example](./api-usage-examples.md). The current retry implementation can run indefinitely on persistent failures; configure an external job timeout and read [retry analysis](./flows/retries-and-exit-status.md).

## Prepare A Calling Workflow

1. Use a runner that supports Linux Docker actions and the image's Linux x64 helper.
2. Check out or otherwise create the upload content in the workflow workspace. The action does not perform checkout or build content.
3. Identify the Steam app and existing Workshop item; confirm the chosen Steam account can update it.
4. Store username/password as protected workflow secrets. Supply the optional seed only after verifying its format is compatible with the helper; the existing [README](../README.md) specifies a standard TOTP seed.
5. Invoke the action with a reviewed ref, app ID, item ID, and relative content path. Optionally provide a changenote.
6. Add caller-level timeout and same-item serialization. Inspect logs carefully and confirm remote publication for initial integration.

The [example page](./api-usage-examples.md) is a step fragment, not a complete workflow. Never test by publishing to an item without permission.

## Local Orientation Without Credentials

The production files are [metadata](../action.yml), [image definition](../Dockerfile), and [script](../entrypoint.sh). Bash syntax validation and in-memory mocks can verify local control flow without network access. See [testing](./testing.md) for observed checks and recommended cases.

The existing bare Docker run example exits one because credential defaults are empty. A successful image build or missing-credential check is not proof of a working Workshop upload.

## Next Reading

Use [upload flow](./flows/workshop-update.md) to understand execution, [troubleshooting](./troubleshooting.md) for failures, and [change guide](./change-guide.md) before editing. [Security policy](../SECURITY.md), [privacy policy](../PRIVACY.md), and [licence](../LICENSE) remain root documents.
