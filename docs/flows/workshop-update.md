# Workshop Update Flow

## Successful Path

1. A caller prepares upload content in its workspace and invokes the [Docker action](../../action.yml). The action itself neither checks out source nor creates distribution content.
2. GitHub Actions builds the [image](../../Dockerfile), mounts the workspace, supplies action input environment variables, and starts the entrypoint.
3. The [script](../../entrypoint.sh) checks username, then password. Missing credentials stop execution with status one before descriptor creation.
4. It expands four input strings and the workspace prefix into `/home/steam/workshop.vdf`, then prints that file. No metadata validation or escaping intervenes.
5. `run_steamcmd` chooses [password-only or seeded authentication](./authentication.md).
6. SteamCMD receives login, `workshop_build_item`, and quit commands in one invocation. The client reads the descriptor and content, interacts with Steam, and returns a status.
7. Status zero sets the local success flag, breaks the loop, and exits zero. The runner observes process success; the action publishes no output value.

```mermaid
sequenceDiagram
    participant W as Calling workflow
    participant E as Entrypoint
    participant T as Optional TOTP helper
    participant S as SteamCMD
    participant V as Valve
    W->>E: Inputs, environment, mounted content
    E->>E: Check credentials; write and print VDF
    opt Nonempty seed
        E->>T: Seed argument
        T-->>E: Code on stdout and status
    end
    E->>S: Login and workshop_build_item(VDF)
    S->>V: Authentication and content upload
    V-->>S: External service result
    S-->>E: Process status
    E-->>W: Exit status and inherited logs
```

## Alternate Paths And Preserved State

A helper failure skips SteamCMD and enters the same retry path as a client failure. A descriptor write or print failure does not prevent login. Each retry uses the same descriptor and content path, but SteamCMD reads the content again; the action makes no immutable content snapshot.

A nonzero client status does not establish that no remote side effect occurred. A connection could fail after remote acceptance; retrying is therefore not an exactly-once transaction. The action does not reconcile the remote result.

The [retry defect](./retries-and-exit-status.md) normally prevents terminal diagnostics on persistent failure. No test or workflow in the repository enforces a publication invariant; [testing evidence](../testing.md) covers only local control flow.

## Dependants And Changes

Consumers rely on the workspace path construction, metadata names, and process status. Changes to the descriptor, authentication command, or success criterion require reviewing [configuration](../configuration.md), [invariants](../invariants.md), and caller examples together.
