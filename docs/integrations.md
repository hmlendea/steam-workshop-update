# Integrations

## GitHub Actions

[Action metadata](../action.yml) defines a Docker action with required app/item/path inputs and an optional changenote. The platform supplies `INPUT_*` variables, workspace context, mounted content, and log collection. Credentials are separate caller-specified environment variables, conventionally sourced from GitHub Secrets; the script does not enforce that source.

There are no repository-owned workflow files, output declarations, GitHub API calls, artifact uploads, or release automation. A workflow author must choose triggers, prepare content, and manage permissions, serialization, and timeouts.

## SteamCMD And Valve

The [script](../entrypoint.sh) hands the client a login command and descriptor path. SteamCMD owns network protocols, account verification, upload implementation, and service diagnostics. No direct HTTP client, endpoint schema, request identifier, or token-refresh mechanism is implemented here.

Username/password and optional generated code cross the command-argument boundary. Descriptor fields and content then cross into the client and external service. The seed is supplied to the helper, not intentionally sent as a Steam login argument; network behaviour inside external binaries was not verified.

Failures return through client status and inherited text output. The wrapper does not classify permission errors, invalid item IDs, connectivity, throttling, or partial remote success.

## Build-Time Services

The [Docker build](../Dockerfile) pulls an upstream image, accesses apt repositories, and fetches a versioned helper from GitHub Releases. Build access is therefore broader than runtime Steam access. No checksum/signature verification, network allowlist, or retry policy is supplied for these downloads beyond tool defaults.

For policy references, consult [privacy](../PRIVACY.md) and [security](../SECURITY.md). For implementation risks rather than policy duplication, consult [security analysis](./security.md).
