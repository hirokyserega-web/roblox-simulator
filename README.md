# roblox-simulator

A basic Roblox simulator game project synced using Rojo.

## Structure
- `src/Server/` -> Runs on server (ServerScriptService.Server)
- `src/Client/` -> Runs on client (StarterPlayer.StarterPlayerScripts.Client)
- `src/Shared/` -> Shared code (ReplicatedStorage.Shared)

## Syncing with Roblox Studio
1. Start the Rojo server:
   ```bash
   rojo serve
   ```
2. Open Roblox Studio.
3. Open the Rojo plugin and click **Connect**.