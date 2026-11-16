[![Donate](https://img.shields.io/badge/-%E2%99%A5%20Donate-%23ff69b4)](https://hmlendea.go.ro/funding)
[![Latest Release](https://img.shields.io/github/v/release/hmlendea/steam-workshop-update)](https://github.com/hmlendea/steam-workshop-update/releases/latest)
[![License](https://img.shields.io/github/license/hmlendea/steam-workshop-update)](https://github.com/hmlendea/steam-workshop-update/blob/master/LICENSE)

# Steam Workshop Update

A Docker-based GitHub Action that updates an existing Steam Workshop item through SteamCMD. The action validates credentials, generates a VDF descriptor from workflow inputs, optionally creates a two-factor authentication code, and invokes SteamCMD to upload the update.

## 📑 Table of Contents

- [Capabilities](#-capabilities)
- [Usage](#-usage)
- [Known Limitations](#-known-limitations)
- [Installation](#-installation)
- [Configuration](#-configuration)
  - [Settings](#settings)
  - [Secret Management](#secret-management)
- [Compatibility](#-compatibility)
- [Integrations](#-integrations)
- [Authentication and Authorisation](#-authentication-and-authorisation)
- [Privacy and Data](#-privacy-and-data)
- [Development](#-development)
  - [Requirements](#requirements)
  - [Setup](#setup)
  - [Build](#build)
  - [Docker](#docker)
  - [Dependencies](#dependencies)
- [Project Structure](#-project-structure)
  - [Directories](#directories)
- [Architecture](#-architecture)
- [Documentation](#-documentation)
- [API Reference](#-api-reference)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)
- [Contributing](#-contributing)
- [Code of Conduct](#-code-of-conduct)
- [Acknowledgements](#-acknowledgements)
- [Security](#-security)
- [Support](#-support)
- [Project Engagement](#-project-engagement)
- [License](#-license)

## ✨ Capabilities

- Updates an existing Steam Workshop item with new content
- Supports Steam Guard two-factor authentication via a standard TOTP seed
- Repeats a failed upload after a two-second delay while the job remains running
- Accepts an optional changenote for each update

## 🚀 Usage

Add the following step to your GitHub Actions workflow:

```yaml
- name: steam-workshop-update
  uses: hmlendea/steam-workshop-update@latest
  with:
    appid: 1158310        # The game's Steam App ID
    itemid: 0000000000    # The mod's Steam Workshop Item ID
    path: 'dist'          # Relative path to the mod directory from the repository root
    changenote: 'Updated' # Optional: description of this update
  env:
    STEAM_USERNAME: ${{ secrets.STEAM_USERNAME }}
    STEAM_PASSWORD: ${{ secrets.STEAM_PASSWORD }}
    STEAM_2FASEED: ${{ secrets.STEAM_2FASEED }}
```

The workflow must prepare the content directory, supply the credentials as secrets, and manage triggers, timeouts, and concurrency.

## ⚠️ Known Limitations

- The action updates an existing Workshop item and cannot create a new item.
- A successful step reflects a zero SteamCMD exit status; the published item is not verified independently.
- Persistent failures normally repeat until the job is cancelled or times out, because the retry counter is reset after each failure.
- Input values, content directory existence, and VDF string escaping are not validated.
- Steam account permissions, item ownership, and network access are required but not checked by the action.

## 📦 Installation

[![Obtain it from GitHub](https://raw.githubusercontent.com/hmlendea/readme-assets/master/badges/stores/github.png)](https://github.com/hmlendea/steam-workshop-update/releases)

Reference the action directly in your workflow:

```yaml
uses: hmlendea/steam-workshop-update@latest
```

## ⚙️ Configuration

The action receives four workflow inputs and three environment variables. Use protected GitHub Actions secrets for credentials.

### Settings

| Section | Key | Type | Default | Required | Description |
|---------|-----|------|---------|----------|-------------|
| Workflow input | `appid` | `String` | None | Yes | Steam App ID of the game that owns the item. |
| Workflow input | `itemid` | `String` | None | Yes | Existing Workshop item identifier. |
| Workflow input | `path` | `String` | None | Yes | Content directory relative to the workspace root. |
| Workflow input | `changenote` | `String` | Attribution message | No | Workshop update description. |

### Secret Management

Supply `STEAM_USERNAME`, `STEAM_PASSWORD`, and optionally `STEAM_2FASEED` through protected workflow secrets. The optional seed is a standard TOTP seed, not the SteamGuard base64 secret.

## 🧩 Compatibility

| Component | Supported Versions | Notes |
|-----------|--------------------|-------|
| GitHub Actions runner | Linux runners that support Docker container actions | Declared as a Docker action (`using: docker`). |
| SteamCMD | Image-provided `cm2network/steamcmd` runtime | Selected by the image base, not by an action input. |

## 🔌 Integrations

| Integration | Compatibility | Purpose | Required |
|-------------|---------------|---------|----------|
| SteamCMD | Docker action runtime | Authenticates with Steam and uploads Workshop content. | Yes |
| steam-totp | Pinned 1.0.1 Linux x64 helper | Generates the two-factor authentication code from the seed. | No |
| GitHub Actions | Docker-compatible runner | Executes the action and supplies inputs and secrets. | Yes |

## 🔐 Authentication and Authorisation

The action authenticates to Steam with the supplied account credentials. A standard TOTP seed enables the optional two-factor authentication flow. The Steam account must have permission to update the selected Workshop item.

## 🛡️ Privacy and Data

Steam Workshop Update processes credentials and upload metadata only to authenticate with Steam and perform the requested upload.

For the detailed description of how the application handles privacy and personal data, see the [Privacy Statement](./PRIVACY.md).

| Data | Purpose | Storage | Retention | Optional |
|------|---------|-----------|-----------|----------|
| Steam credentials | Steam authentication | Workflow environment and SteamCMD process | Workflow execution | Username and password required; TOTP seed optional |
| Workshop metadata | Select and describe the upload | Workflow workspace and SteamCMD descriptor | Workflow execution | Changenote optional |

## 🛠️ Development

### Requirements

- [Docker](https://docs.docker.com/get-docker/)

### Setup

Clone the repository and build the Docker image locally:

```bash
git clone https://github.com/hmlendea/steam-workshop-update.git
cd steam-workshop-update
docker build -t steam-workshop-update .
```

### Build

```bash
docker build -t steam-workshop-update .
```

### Docker

```bash
docker run --rm \
  --env STEAM_USERNAME \
  --env STEAM_PASSWORD \
  --env STEAM_2FASEED \
  --env INPUT_APPID \
  --env INPUT_ITEMID \
  --env INPUT_CHANGENOTE \
  --env INPUT_PATH \
  --volume "$PWD":/github/workspace \
  steam-workshop-update
```

A run without credentials exits with status `1`, which validates only the early credential check.

### Dependencies

| Package | Version | Scope | Purpose |
|---------|---------|-------|---------|
| `cm2network/steamcmd` | Image base | Runtime | Provides SteamCMD for authentication and upload. |
| `steam-totp` | 1.0.1 | Optional | Generates a Steam two-factor authentication code. |
| `wget` | Distribution package | Build | Downloads the pinned TOTP helper during the image build. |

## 🗂️ Project Structure

The repository contains the action metadata, Docker image definition, entrypoint, policies, and supporting documentation.

### Directories

| Directory | Purpose |
|-----------|---------|
| `.github/` | Repository hosting metadata and the funding configuration. |
| `docs/` | Detailed architecture, behaviour, configuration, security, and testing documentation. |

## 🏗️ Architecture

Steam Workshop Update is a Docker-based GitHub Action that updates an existing Steam Workshop item through SteamCMD.

See the [Architecture Documentation](./ARCHITECTURE.md) for the system context, principal components, runtime flows, ownership boundaries, dependencies, constraints, and extension points.

## 📚 Documentation

| Resource | Description |
|----------|-------------|
| [Documentation index](docs/INDEX.md) | Index of repository documentation. |
| [Quick start](docs/quick-start.md) | Shortest path to a working workflow step. |
| [Configuration](docs/configuration.md) | Inputs, environment variables, and defaults. |
| [Workshop update flow](docs/flows/workshop-update.md) | End-to-end execution sequence. |
| [Retries and exit status](docs/flows/retries-and-exit-status.md) | Retry behaviour and exit contract. |
| [Testing](docs/testing.md) | Available testing evidence and limitations. |
| [API usage examples](docs/api-usage-examples.md) | Workflow examples and variations. |

## 🌐 API Reference

The action exposes workflow inputs and a credential environment rather than an HTTP API. The interface reference records the descriptor fields, credential variables, and the observable exit status.

See the [Interface Reference](docs/api-reference/INDEX.md) for the public interface catalogue.

## 🩺 Troubleshooting

See [Troubleshooting Guide](./docs/troubleshooting.md) for diagnostic procedures and resolutions to recurring problems.

## ❓ FAQ

See the [Frequently Asked Questions](./docs/faq.md) for responses to frequently raised inquiries.

## 🤝 Contributing

You are welcome to submit any suggestion, feedback, or modification to this project.

When doing so, please:
- Maintain cross-platform compatibility
- Preserve the existing public contract unless a breaking change is intentional
- Submit focused pull requests that conform to the existing code style
- Maintain your branch synchronised with `master`
- Revise the documentation when functionality changes
- Raise a new [issue](https://github.com/hmlendea/steam-workshop-update/issues) for problems or suggestions

See the [Contributing Guidelines](./CONTRIBUTING.md) for details on how to report issues, suggest enhancements, and submit changes.

## 📜 Code of Conduct

See the [Code of Conduct](./CODE_OF_CONDUCT.md) for the standards of conduct expected in all project spaces.

## 🙏 Acknowledgements

- [arma-actions/workshop-upload](https://github.com/arma-actions/workshop-upload)
- [Weilbyte/steam-workshop-upload](https://github.com/Weilbyte/steam-workshop-upload)

## 🔒 Security

Steam Workshop Update delegates authentication and publication to SteamCMD and does not implement its own credential storage, transport security, or remote state verification.

For information on reporting security vulnerabilities, see the [Security Policy](./SECURITY.md).

## 💬 Support

For support, please [open an issue](https://github.com/hmlendea/steam-workshop-update/issues).

## 💝 Project Engagement

Discovered a problem with Steam Workshop Update or have a suggestion for it? [Open an issue](https://github.com/hmlendea/steam-workshop-update/issues)!

If you find this project useful, consider [funding it](https://hmlendea.go.ro/funding) or starring ⭐️ it on GitHub!

[![Donate](https://raw.githubusercontent.com/hmlendea/readme-assets/master/donate_generic.png)](https://hmlendea.go.ro/funding)

## 📄 License

This project is being distributed under the `GNU General Public License v3.0`.
See [LICENSE](./LICENSE) for additional information.
