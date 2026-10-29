# Interface Reference

## HTTP Endpoint Summary

This repository exposes no HTTP server, controllers, or endpoints. Consequently there are no per-controller files, request/response JSON schemas, route versions, HTTP authentication schemes, or repository-defined HTTP rate limits to catalogue.

| Method | Path | Controller | Action | Auth |
|---|---|---|---|---|
| Not applicable | No routes | None | None | No HTTP scheme |

SteamCMD uses external Steam services; those protocols are not an API implemented here.

## Actual Public Interface

| Interface | Definition | Result |
|---|---|---|
| GitHub Action inputs | [action.yml](../../action.yml) | Descriptor fields, not an HTTP response |
| Credential environment | [Configuration](../configuration.md) | Password-only or seeded login |
| Container process | [Entrypoint component](../components/entrypoint.md) | Exit status and logs |

There are no declared action outputs, version negotiation, or built-in throttling policy. Caller-selected action refs version the code; the optional helper's release is selected at image build time. Secret environment values are the credential interface, not repository-enforced access-control policies.

See [usage examples](../api-usage-examples.md), [upload flow](../flows/workshop-update.md), [external tool contracts](../components/external-tools.md), and [data model](../data-model.md).
