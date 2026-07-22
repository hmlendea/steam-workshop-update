[![Donate](https://img.shields.io/badge/-%E2%99%A5%20Donate-%23ff69b4)](https://hmlendea.go.ro/funding)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://gnu.org/licenses/gpl-3.0)

# steam-workshop-update

A GitHub Action that updates a mod on the Steam Workshop. Supports Steam Guard two-factor authentication via a standard TOTP seed and retries the upload automatically on failure.

## ✨ Features

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

## 🛠️ Development

### Requirements

- [Docker](https://docs.docker.com/get-docker/)

### Docker

```bash
docker build -t steam-workshop-update .
docker run --rm steam-workshop-update
```

## 🤝 Contributing

Contributions are welcome. Please:

- Keep the pull requests focused and consistent with the existing code style

## 🙏 Acknowledgements

Inspired by:

- [arma-actions/workshop-upload](https://github.com/arma-actions/workshop-upload)
- [Weilbyte/steam-workshop-upload](https://github.com/Weilbyte/steam-workshop-upload)

## 💝 Support

Found a bug or have a suggestion? [Open an issue](https://github.com/hmlendea/steam-workshop-update/issues)!

If you find this project useful, consider [funding it](https://hmlendea.go.ro/funding) or giving a ⭐️ on GitHub!

[![Donate](https://raw.githubusercontent.com/hmlendea/readme-assets/master/donate_generic.png)](https://hmlendea.go.ro/funding)

## 📄 License

Licensed under the `GNU General Public License v3.0` or later.
See [LICENSE](./LICENSE) for details.
