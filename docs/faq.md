# Frequently Asked Questions

## Is This An HTTP API?

No. It is a Docker GitHub Action. See the [interface reference](./api-reference/INDEX.md); there are no controllers, routes, JSON responses, or action outputs.

## Does It Build Or Check Out My Mod?

No. Prepare the complete content directory before invoking the action. The script only constructs its path and asks SteamCMD to upload it. See [quick start](./quick-start.md).

## Are Retries Limited To Three Attempts?

Not currently in an ordinary environment. The failure counter reads `ATTEMPTS` instead of `ATTEMPTS_CURRENT`, so persistent failures normally repeat indefinitely. See [analysis and reproduction](./flows/retries-and-exit-status.md).

## Does Omitting The Seed Disable Steam Guard?

No. It selects login without a generated-code argument. Account/service authentication requirements remain external. See [authentication](./flows/authentication.md).

## Does Success Prove The Correct Content Is Published?

Only indirectly: the wrapper trusts SteamCMD status zero. It does not query Workshop or compare remote content hashes. Initial integrations should verify the target item explicitly.

## Can I Use An Absolute Content Path?

The script always concatenates `${GITHUB_WORKSPACE}/${INPUT_PATH}`. It does not treat an absolute-looking input as an override or enforce containment. Prefer a verified relative directory; see [configuration](./configuration.md).

## Are Credentials Or Logs Automatically Erased?

The script has no cleanup routine. It avoids deliberate credential fields in the VDF, but supplies credentials as arguments and inherits environment to children. Client state, container removal, host storage, and retained logs need separate review. See [state](./state-and-persistence.md) and [security](./security.md).

## Where Are The Tests And Roadmap?

No committed automated tests, CI workflow, or root roadmap were found. [Testing](./testing.md) records the safe checks performed during documentation generation, not a persistent regression suite.

## Why Is There No Second Architecture Overview?

The existing [root architecture](../ARCHITECTURE.md) remains the architecture entry point. Component, flow, and contract pages complement it without reproducing it; [open questions](./ambiguities-and-open-questions.md) capture source-verified discrepancies.
