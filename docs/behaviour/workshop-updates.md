# Workshop Update Behaviour

## User-Visible Contract

The action uploads content for the app and existing Workshop item selected by the caller. It does not choose an item, build assets, edit content, or return a new item identifier. The caller supplies a relative content directory and credentials, and observes workflow logs and step status.

An omitted changenote receives the attribution default from [metadata](../../action.yml) when invoked through GitHub Actions. An explicit changenote is inserted unchanged into the VDF. No local escaping, length limit, or markup conversion is performed.

## Preconditions

The workflow must prepare the complete directory before calling the action. Steam account ownership/permission, item compatibility, network access, and acceptable authentication are required by the external service but not checked independently. Supplying a seed switches authentication modes; omitting it is not a guarantee that Steam will permit password-only login.

## Observable Outcomes

- Missing credentials: fatal message naming the missing variable; status one.
- Upload path: printed descriptor, attempt messages, and inherited external-tool output.
- Client status zero: step succeeds; no verification query follows.
- Repeated failures: normally repeated attempts until success or external cancellation because of the [counter defect](../flows/retries-and-exit-status.md).
- Terminal failure, when reached: client log dumping and status two.

There is no dry-run option, content diff, rollback, scheduled trigger, cancellation handler, or item-level concurrency guard. Re-running a step can publish again; this is not an idempotency guarantee. See [examples](../api-usage-examples.md), [troubleshooting](../troubleshooting.md), and the full [execution flow](../flows/workshop-update.md).
