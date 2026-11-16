[![Donate](https://img.shields.io/badge/-%E2%99%A5%20Donate-%23ff69b4)](https://hmlendea.go.ro/funding)
[![Latest Release](https://img.shields.io/github/v/release/hmlendea/steam-workshop-update)](https://github.com/hmlendea/steam-workshop-update/releases/latest)
[![License](https://img.shields.io/github/license/hmlendea/steam-workshop-update)](https://github.com/hmlendea/steam-workshop-update/blob/master/LICENSE)

# Steam Workshop Update

A composite GitHub Action that installs Valve's SteamCMD client natively on the runner and updates an existing Steam Workshop item. The action validates its inputs, generates a VDF descriptor, optionally creates a two-factor authentication code, invokes SteamCMD, and retries failed uploads.

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
  - [Test](#test)
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
- Retries a failed upload up to three attempts before failing the step
- Validates inputs and rejects paths outside the workflow workspace
- Redacts passwords, seeds, and generated codes from command output
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
- SteamCMD is downloaded from the Steam CDN at install time without a pinned version or checksum.
- A hung SteamCMD client can stall the step, so a caller-level job timeout remains necessary.
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
| GitHub Actions runner | Linux runners with composite action support | Declared as a composite action (`using: composite`). |
| 32-bit C runtime | `lib32gcc-s1` or `glibc.i686` | Required by the i386 SteamCMD client; installed when missing. |
| SteamCMD | Steam CDN `steamcmd_linux.tar.gz` | Downloaded and bootstrapped at install time. |

## 🔌 Integrations

| Integration | Compatibility | Purpose | Required |
|-------------|---------------|---------|----------|
| SteamCMD | Downloaded from the Steam CDN | Authenticates with Steam and uploads Workshop content. | Yes |
| steam-totp | Pinned release 1.0.1 Linux x64 | Generates the two-factor authentication code from the seed. | No |
| GitHub Actions | Linux runner with composite action support | Executes the action and supplies inputs and secrets. | Yes |

## 🔐 Authentication and Authorisation

The action authenticates to Steam with the supplied account credentials. A standard TOTP seed enables the optional two-factor authentication flow. The Steam account must have permission to update the selected Workshop item.

## 🛡️ Privacy and Data

Steam Workshop Update processes credentials and upload metadata only to authenticate with Steam and perform the requested upload.

For the detailed description of how the application handles privacy and personal data, see the [Privacy Statement](./PRIVACY.md).

| Data | Purpose | Storage | Retention | Optional |
|------|---------|-----------|-----------|----------|
| Steam credentials | Steam authentication | Runner environment and SteamCMD process | Workflow execution | Username and password required; TOTP seed optional |
| Workshop metadata | Select and describe the upload | Runner temporary directory and SteamCMD descriptor | Workflow execution | Changenote optional |

## 🛠️ Development

### Requirements

- Bash and `bash -n` for syntax checks
- A Linux environment for native execution; Docker only if you want the local test image

### Setup

Clone the repository:

```bash
git clone https://github.com/hmlendea/steam-workshop-update.git
cd steam-workshop-update
```

### Build

The production action is composite and installs SteamCMD directly on the runner, so there is no build step. `Dockerfile` builds a local test image only:

```bash
docker build -t steam-workshop-update .
```

### Test

```bash
bash tests/test_entrypoint.sh
```

### Docker

```bash
docker run --rm steam-workshop-update
```

A run without credentials exits with status `1`, which validates only the early credential check.

### Dependencies

| Package | Version | Scope | Purpose |
|---------|---------|-------|---------|
| SteamCMD | Steam CDN archive | Runtime | Authenticates with Steam and uploads Workshop content. |
| `steam-totp` | 1.0.1 | Optional | Generates a Steam two-factor authentication code. |
| 32-bit C runtime | Distribution package | Runtime | Runs the i386 SteamCMD client. |
| `curl` or `wget`, `tar` | Runner image | Build and runtime | Downloads and extracts the client and helper. |

## 🗂️ Project Structure

The repository contains the action metadata, the SteamCMD installer, the entrypoint, the local test image, the test suite, policies, and supporting documentation.

### Directories

| Directory | Purpose |
|-----------|---------|
| `.github/` | Repository hosting metadata and the funding configuration. |
| `docs/` | Detailed architecture, behaviour, configuration, security, and testing documentation. |
| `scripts/` | SteamCMD and helper installation performed by the first action step. |
| `tests/` | Unit and integration test scripts for the entrypoint and installer. |

## 🏗️ Architecture

Steam Workshop Update is a composite GitHub Action that installs Valve's SteamCMD client natively on the runner and drives it from a Bash entrypoint to update an existing Workshop item.

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

Steam Workshop Update delegates authentication and publication to SteamCMD, downloads its client and helper over HTTPS at install time, and redacts credentials from the output it prints.

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
