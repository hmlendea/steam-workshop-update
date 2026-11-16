# Frequently Asked Questions

## Is This An HTTP API?

No. It is a composite GitHub Action. See the [interface reference](./api-reference/INDEX.md); there are no controllers, routes, JSON responses, or action outputs.

## Does It Build Or Check Out My Mod?

No. Prepare the complete content directory before invoking the action. The script only constructs its path and asks SteamCMD to upload it. See [quick start](./quick-start.md).

## Are Retries Limited To Three Attempts?

Yes. The counter is incremented correctly and the client command is tested as an `if` condition, so a persistent failure stops after the third attempt and prints both Steam logs before exiting two. See [retry analysis](./flows/retries-and-exit-status.md).

## Does Omitting The Seed Disable Steam Guard?

No. It selects login without a generated-code argument. Account/service authentication requirements remain external. See [authentication](./flows/authentication.md).

## Does Success Prove The Correct Content Is Published?

Only indirectly: the wrapper trusts SteamCMD status zero. It does not query Workshop or compare remote content hashes. Initial integrations should verify the target item explicitly.

## Can I Use An Absolute Content Path?

The script always concatenates `${GITHUB_WORKSPACE}/${INPUT_PATH}` and then requires the resolved path to stay inside the workspace. An absolute-looking input is not treated as an override. Prefer a verified relative directory; see [configuration](./configuration.md).

## Are Credentials Or Logs Automatically Erased?

The script has no cleanup routine. `sanitize_output` redacts known credential values from wrapper output, but supplies credentials as arguments and inherits environment to children. Client state, runner storage, and retained logs need separate review. See [state](./state-and-persistence.md) and [security](./security.md).

## Where Are The Tests And Roadmap?

[tests/test_entrypoint.sh](../tests/test_entrypoint.sh) is the committed unit suite; it runs with Bash only. No CI workflow or root roadmap exists, so the suite is not enforced automatically. See [testing](./testing.md).

## Why Is There No Second Architecture Overview?

The existing [root architecture](../ARCHITECTURE.md) remains the architecture entry point. Component, flow, and contract pages complement it without reproducing it; [open questions](./ambiguities-and-open-questions.md) capture source-verified discrepancies.
