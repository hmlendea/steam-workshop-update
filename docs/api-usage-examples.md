# Action Usage Examples

## Workflow Step

The action is not an HTTP API. This example is a job fragment, not a complete workflow. Prepare `dist` before these steps; choose real app/item IDs and replace `REVIEWED_COMMIT_SHA` with an actual reviewed full commit hash.

```yaml
- name: Update Workshop item
  uses: hmlendea/steam-workshop-update@REVIEWED_COMMIT_SHA
  with:
    appid: '1158310'
    itemid: '0000000000'
    path: 'dist'
    changenote: 'Updated content'
  env:
    STEAM_USERNAME: ${{ secrets.STEAM_USERNAME }}
    STEAM_PASSWORD: ${{ secrets.STEAM_PASSWORD }}
    STEAM_2FASEED: ${{ secrets.STEAM_2FASEED }}
```

The identifiers are illustrative, not a verified writable item. No workflow token permission grants Steam account rights. Do not run this with production credentials merely to validate syntax.

## Variants

Omit the `STEAM_2FASEED` environment entry for the password-only branch. This changes command construction; Steam may still require additional authentication. Omit `changenote` to use the exact default in [configuration](./configuration.md).

The existing [README](../README.md) uses `@latest`; that is a mutable ref. A reviewed full commit hash reduces action-source movement but does not pin the floating base image and apt dependencies.

## Results And Failure Examples

There is no JSON response or action output to read. A missing username prints:

```text
FATAL: Environment variable STEAM_USERNAME is required but not provided.
```

and exits one. A successful client invocation causes exit zero. Persistent failure does not currently enforce the advertised three-attempt cap; see [retry semantics](./flows/retries-and-exit-status.md). External client diagnostics are not stable repository-owned error schemas.

Use [quick start](./quick-start.md) for prerequisites and [security guidance](./security.md) before enabling live publishing.
