[![Donate](https://img.shields.io/badge/-%E2%99%A5%20Donate-%23ff69b4)](https://hmlendea.go.ro/funding)
[![License](https://img.shields.io/github/license/hmlendea/steam-workshop-update)](https://github.com/hmlendea/steam-workshop-update/blob/master/LICENSE)

# Steam Workshop Update

A Docker-based GitHub Action that updates an existing Steam Workshop item through SteamCMD. The action validates credentials, generates a VDF descriptor from workflow inputs, optionally creates a two-factor authentication code, and invokes SteamCMD to upload the update.

## 📑 Table of Contents

- [Capabilities](#-capabilities)
- [Usage](#-usage)
  - [Inputs](#inputs)
  - [Environment Variables](#environment-variables)
- [Known Limitations](#-known-limitations)
- [Installation](#-installation)
- [Configuration](#-configuration)
  - [Settings](#settings)
  - [Secret Management](#secret-management)
- [Integrations](#-integrations)
- [Authentication and Authorisation](#-authentication-and-authorisation)
- [Privacy and Data](#-privacy-and-data)
- [Development](#-development)
  - [Requirements](#requirements)
  - [Setup](#setup)
  - [Docker](#docker)
  - [Dependencies](#dependencies)
- [Project Structure](#-project-structure)
  - [Directories](#directories)
- [Architecture](#-architecture)
- [Documentation](#-documentation)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)
- [Contributing](#-contributing)
- [Code of Conduct](#-code-of-conduct)
- [Acknowledgements](#-acknowledgements)
- [Security](#-security)
- [Project Engagement](#-project-engagement)
- [License](#-license)

## ✨ Capabilities

- Updates an existing Steam Workshop item with new content
- Supports Steam Guard two-factor authentication via a standard TOTP seed
- Retries the upload automatically on failure, up to three times
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

### Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `appid` | Yes | The game's Steam App ID |
| `itemid` | Yes | The Steam Workshop Item ID of the mod to update |
| `path` | Yes | Relative path to the mod directory from the repository root |
| `changenote` | No | Description of this update (defaults to a standard attribution message) |

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `STEAM_USERNAME` | Yes | The Steam account username |
| `STEAM_PASSWORD` | Yes | The Steam account password |
| `STEAM_2FASEED` | No | The Steam account 2FA seed (standard TOTP, not the SteamGuard base64 secret) |

## ⚠️ Known Limitations

- The calling workflow must prepare the content directory and manage triggers, timeouts, and concurrency.
- The action updates an existing item and does not create a new Workshop item.
- The action depends on Steam account permissions, network access, and SteamCMD behaviour.

## 📦 Installation

This action is distributed through the GitHub Marketplace. Reference it directly in your workflow:

[![Obtain it from GitHub](https://raw.githubusercontent.com/hmlendea/readme-assets/master/badges/stores/github.png)](https://github.com/hmlendea/steam-workshop-update)

```yaml
uses: hmlendea/steam-workshop-update@latest
```

## ⚙️ Configuration

The action receives four workflow inputs and three environment variables. Use protected GitHub Actions secrets for credentials.

### Settings

| Section | Key | Type | Default | Required | Description |
|---------|-----|------|---------|----------|-------------|
| Workflow input | `appid` | String | None | Yes | Steam App ID. |
| Workflow input | `itemid` | String | None | Yes | Existing Workshop Item ID. |
| Workflow input | `path` | String | None | Yes | Content directory relative to the workspace. |
| Workflow input | `changenote` | String | Standard attribution message | No | Workshop update description. |

### Secret Management

Supply `STEAM_USERNAME`, `STEAM_PASSWORD`, and optionally `STEAM_2FASEED` through protected workflow secrets.

## 🔌 Integrations

| Integration | Compatibility | Purpose | Required |
|-------------|---------------|---------|----------|
| SteamCMD | Docker action runtime | Authenticates with Steam and uploads Workshop content. | Yes |
| GitHub Actions | Docker-compatible runner | Executes the action and supplies inputs and secrets. | Yes |

## 🔐 Authentication and Authorisation

The action authenticates to Steam with the supplied account credentials. A standard TOTP seed enables the optional two-factor authentication flow. The Steam account must have permission to update the selected Workshop item.

## 🛡️ Privacy and Data

Steam Workshop Update processes credentials and upload metadata only to authenticate with Steam and perform the requested upload.

For the detailed description of how the application handles privacy and personal data, see [PRIVACY.md](./PRIVACY.md).

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
docker build -t steam-workshop-update .
```

### Docker

```bash
docker build -t steam-workshop-update .
docker run --rm steam-workshop-update
```

### Dependencies

| Package | Version | Scope | Purpose |
|---------|---------|-------|---------|
| SteamCMD | Runtime-provided | Runtime | Authenticates with Steam and uploads Workshop content. |
| TOTP helper | Runtime-provided | Optional | Generates a Steam two-factor authentication code. |

## 🗂️ Project Structure

The repository contains the action metadata, Docker image definition, entrypoint, policies, and supporting documentation.

### Directories

| Directory | Purpose |
|-----------|---------|
| `docs/` | Detailed architecture, behaviour, configuration, security, and testing documentation. |

## 🏗️ Architecture

Steam Workshop Update is a Docker-based GitHub Action that updates an existing Steam Workshop item through SteamCMD.

See the [architecture documentation](./ARCHITECTURE.md) for the system context, principal components, runtime flows, ownership boundaries, dependencies, constraints, and extension points.

## 📚 Documentation

| Resource | Description |
|----------|-------------|
| [Documentation index](docs/INDEX.md) | Index of repository documentation. |
| [Configuration](docs/configuration.md) | Inputs, environment variables, and defaults. |
| [Testing](docs/testing.md) | Available testing evidence and limitations. |
| [API usage examples](docs/api-usage-examples.md) | Workflow examples and variations. |

## 🩺 Troubleshooting

| Symptom | Probable Cause | Resolution |
|---------|----------------|------------|
| Authentication fails | Credentials or 2FA seed are invalid or incompatible. | Verify protected secrets and the documented TOTP seed format. |
| Upload does not finish | SteamCMD or the network is unavailable. | Review workflow logs and configure an explicit job timeout. |
| Concurrent updates conflict | Multiple workflows target the same Workshop item. | Serialise updates with a workflow concurrency group. |

## ❓ FAQ

See the [Frequently Asked Questions](docs/faq.md) for responses to frequently raised inquiries.

## 🤝 Contributing

You are welcome to submit any suggestion, feedback, or modification to this project.

When doing so, please:
- Maintain cross-platform compatibility
- Submit focused pull requests that conform to the existing code style
- Maintain your branch synchronised with `master`
- Revise the documentation when functionality changes

See the [contributing guidelines](./CONTRIBUTING.md) for details on how to report issues, suggest enhancements, and submit changes.

## 📜 Code of Conduct

See the [Code of Conduct](./CODE_OF_CONDUCT.md) for the standards of conduct expected in all project spaces.

## 🙏 Acknowledgements

Inspired by:

- [arma-actions/workshop-upload](https://github.com/arma-actions/workshop-upload)
- [Weilbyte/steam-workshop-upload](https://github.com/Weilbyte/steam-workshop-upload)

## 🔒 Security

Steam Workshop Update follows the repository security policy for handling vulnerability reports.

For information on reporting security vulnerabilities, see [SECURITY.md](./SECURITY.md).

## 💝 Project Engagement

Discovered a problem or have a suggestion? [Open an issue](https://github.com/hmlendea/steam-workshop-update/issues)!

If you find this project useful, consider [funding it](https://hmlendea.go.ro/funding) or starring ⭐️ it on GitHub!

[![Donate](https://raw.githubusercontent.com/hmlendea/readme-assets/master/donate_generic.png)](https://hmlendea.go.ro/funding)

## 📄 License

This project is being distributed under the `GNU General Public License v3.0` or later.
See [LICENSE](./LICENSE) for additional information.

