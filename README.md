# About

Takes inspiration from:
 - [workshop-upload](https://github.com/arma-actions/workshop-upload)
 - [steam-workshop-upload](https://github.com/Weilbyte/steam-workshop-upload)

# Usage

```yaml
- name: steam-workshop-update
  uses: hmlendea/steam-workshop-update@latest
  with:
    appid: 1158310 # The game's Steam App ID
    itemid: 0000000000 # The mod's Steam Workshop Item ID
    path: 'dist' # Relative path to your mod's folder, starting from the repository root
  env:
    STEAM_USERNAME: ${{ secrets.STEAM_USERNAME }} # The Steam account username
    STEAM_PASSWORD: ${{ secrets.STEAM_PASSWORD }} # The Steam account password
    STEAM_2FASEED: ${{ secrets.STEAM_2FASEED }} # The Steam account 2FA seed (standard TOTP, not the SteamGuard base64 secret)
```
