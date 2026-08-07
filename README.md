
---

# Roblox Serverhop Module
**A robust, file-persistent Server Hopper designed for Roblox executors.** 

This module allows your scripts to hop between servers efficiently while avoiding duplicates. It tracks visited servers using a local JSON file, ensuring you don't join the same server twice within the same hour.

## Key Features
- **Smart Avoidance:** Saves visited Server IDs to `server-hop-temp.json`.
- **Auto-Reset:** Automatically clears the cache every hour.
- **Queue Logic:** Skips full servers and uses pagination to find the best available spot.
- **Lightweight:** Minimal overhead, optimized for high-performance scripts.

## Installation & Usage

Since this is a **Module**, you can either bundle it with your script or load it via `loadstring`.

### 1. Basic Integration
If you are building a larger script and want to include this module:

```lua
local serverhop = loadstring(game:HttpGet("https://raw.githubusercontent.com/radmin1337/Roblox-Serverhop-Module/refs/heads/main/serverhop.lua"))()
serverhop:Teleport(game.PlaceId) -- Teleport to a new server of the current game
```

### 2. Custom Place ID
You can also use it to hop to different games:

```lua
local serverhop = loadstring(game:HttpGet("https://raw.githubusercontent.com/radmin1337/Roblox-Serverhop-Module/refs/heads/main/serverhop.lua"))()
serverhop:Teleport(123456789) -- Replace with target PlaceId
```

## Technical Details
- **File System:** Uses `readfile`, `writefile`, and `delfile`. Ensure your executor supports these (Standard on Synapse, Script-Ware, Krnl, Fluxus, etc.).
- **API:** Queries the Roblox Public Games API (`v1/games/`).
- **Persistence:** The `server-hop-temp.json` file is stored in your executor's `workspace` folder.

---
