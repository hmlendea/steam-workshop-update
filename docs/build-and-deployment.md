# Build And Deployment

## Build Pipeline

[Action metadata](../action.yml) selects Docker execution with the repository [Dockerfile](../Dockerfile). The caller's runner builds an image from the selected action revision. Build stages are dependency installation, script copy/permission setup, and helper download/permission setup. There is one named stage; no artifact packaging or repository-owned publish workflow exists.

Build requires access to the base-image registry, apt repositories, and GitHub Releases. Runtime requires Steam access. No environment-specific deployment files, deployment database, readiness probe, or long-running server exist.

## Supported Topology And Constraints

The implementation targets a Linux container and downloads a Linux x64 helper. Use a runner supporting GitHub Docker actions; self-hosted execution additionally needs a compatible container runtime and permissions. The repository does not establish ARM compatibility, a tested OS matrix, or pinned transitive runtime versions.

The upstream `root` image tag is mutable. No final `USER` override appears in this Dockerfile. Do not assume an exact base image identity or runtime user without inspecting the actual built image.

## Local Verification Levels

| Level | What It Establishes | What It Does Not |
|---|---|---|
| Bash syntax check | Script parses | Runtime tools or control-flow correctness |
| Image build | Dependencies fetched, installation commands succeed | Steam login/upload |
| Bare image run | Empty-credential validation | Correct action inputs or publication |
| Mocked orchestration | Selected branches and status handling | Network/client semantics |
| Authorized integration run | Behaviour for one concrete environment/account/item | General service reliability or exactly-once publication |

Direct Docker use must explicitly supply `INPUT_*`, workspace path/mount, and credentials; GitHub metadata defaults are not applied automatically. The image's `CMD ["."]` is not an upload path option.

## Caller Responsibilities

Choose an action ref, prepare content, bind secrets, set a job timeout, and serialize updates per item. Review mutable dependencies separately even if pinning the action source. The normal persistent-failure path is unbounded due to the [retry defect](./flows/retries-and-exit-status.md).

The [root architecture](../ARCHITECTURE.md) remains the overview; [container internals](./components/container-image.md) and [dependencies](./dependencies.md) specify the actual build contracts. No deployment or integration run was performed during documentation generation.
