<p align="center">
  <img src="https://img.shields.io/badge/KIF%20Mod%20Manager-v1.0.0-green?style=for-the-badge" alt="Mod Manager v1.0.0">
</p>

# KIF Mod Manager

The **KIF Mod Manager** is a built-in mod management system for Kuray's Infinite Fusion (KIF). Browse, install, update, and manage mods entirely from within the game — no manual file copying needed.

All community mods are hosted on the [**KIF-Mods/mods**](https://github.com/KIF-Mods/mods) GitHub repository.

---

## Table of Contents

- [For Players](#for-players)
  - [Getting Started](#getting-started)
  - [Mod Browser](#mod-browser)
  - [Modpacks](#modpacks)
  - [Share Codes](#share-codes)
  - [Mod Settings](#mod-settings)
- [For Modders](#for-modders)
  - [Creating a Mod](#creating-a-mod)
  - [Creating a Modpack](#creating-a-modpack)
  - [Uploading & Deleting](#uploading--deleting)
  - [mod.json Reference](#modjson-reference)
  - [modpack.json Reference](#modpackjson-reference)
  - [Settings Definitions](#settings-definitions)
  - [Tags](#tags)
  - [Repository Structure](#repository-structure)

---

## For Players

### Getting Started

The Mod Manager is accessible from the **title screen**. From there you can:

- View all installed mods and toggle them on/off
- Open the **Mod Browser** to find new mods
- Access **Modder Tools** to create your own mods
- Check for **Mod Manager updates** (shown as a yellow banner when available — press `U` to update)

### Mod Browser

The Mod Browser has three tabs:

| Tab | Description |
|-----|-------------|
| **Mods** | Browse all mods on the KIF-Mods repository. See names, descriptions, tags, versions, and install status. Install or update with `Z`. |
| **Modpacks** | Browse curated collections of mods. Install an entire modpack at once — all included mods are downloaded together. |
| **Share Code** | Import or export share codes to quickly share your mod setup with others. |

**Controls:**

| Key | Action |
|-----|--------|
| `Z` / Click | Install / Update selected mod or modpack |
| `X` / Esc | Back |
| `S` | Search |
| `T` | Filter by tag |
| `Tab` | Switch tab |
| `1` `2` `3` | Jump to Mods / Modpacks / Share Code tab |

**Auto-Dependencies:** When installing a mod that requires other mods, the Mod Manager detects missing dependencies and offers to download them automatically. When enabling a mod, disabled dependencies are auto-enabled with your confirmation.

**Progress Overlay:** Multi-mod downloads (modpacks, dependency chains) show a full progress overlay with mod name, file count, and a cancel option. Cancelling mid-download lets you keep what was already downloaded or undo everything.

### Modpacks

Modpacks are curated sets of mods bundled together. They appear in the **Modpacks** tab of the Mod Browser.

- Each modpack lists the mods it contains with their install status
- Installing a modpack downloads all included mods at once
- Mods can have optional minimum version requirements
- Dependencies of included mods are resolved automatically

### Share Codes

Share codes let you share your exact mod setup with other players.

**Exporting:**
- From the **Installed Mods** screen, press the **Share Code** footer button
- A compact code (`KIF-...`) is generated from all your enabled mods and copied to your clipboard
- Send the code to friends via Discord, chat, etc.

**Importing:**
- Go to the **Share Code** tab in the Mod Browser
- Select **Import** — the Mod Manager checks your clipboard automatically
- If a valid `KIF-` code is found, it shows the decoded mod list with install status
- Install missing mods or update older versions directly from there
- You can also type/paste a code manually

### Mod Settings

Many mods expose configurable settings (toggles, sliders, selections). Access them from the **Installed Mods** screen by selecting a mod and choosing **Settings**.

Settings are stored per-mod and accessible at runtime via `$mod_manager_settings["mod_id"]`.

---

## For Modders

### Creating a Mod

1. Open the Mod Manager from the title screen
2. Go to **Modder Tools** → **Create** → **Mod**
3. Follow the wizard:
   - Mod name (auto-generates an ID)
   - Author name
   - Description
   - Version (default `1.0.0`)
   - Tags (multi-select)
   - Dependencies (pick from known mods)
   - Incompatibilities
4. Output is generated in `ModDev/<mod_id>/`:
   - `mod.json` — the mod manifest
   - `main.rb` — your entry point with a template
5. Write your code in `main.rb`
6. Test by copying the folder to `Mods/` and launching the game
7. Upload via **Modder Tools** → **Upload** → **Mod**

### Creating a Modpack

1. **Modder Tools** → **Create** → **Modpack**
2. Enter name, author, description, version, and tags
3. Select mods to include — for each mod you can optionally set a minimum version
4. Output: `ModDev/<pack_id>/modpack.json`
5. Upload via **Modder Tools** → **Upload** → **Modpack**

> **Note:** Uploading modpacks requires verified team membership with write access to the [KIF-Mods](https://github.com/KIF-Mods/mods) repository.

### Uploading & Deleting

All upload/delete operations are available in **Modder Tools** with submenu navigation:

| Action | Mod | Modpack |
|--------|-----|---------|
| **Create** | Guided wizard → `ModDev/<id>/mod.json` + `main.rb` | Guided wizard → `ModDev/<id>/modpack.json` |
| **Update** | Edit name, description, version, tags, deps, incompatibilities | Edit name, description, version, tags, mod list |
| **Upload** | Runs `publish_mod.bat` / `.sh` — write access or fork+PR | Runs `publish_modpack.bat` / `.sh` — **write access required** |
| **Delete** (local) | Removes folder from `ModDev/` | Removes folder from `ModDev/` |
| **Delete from Repo** | Runs `delete_mod.bat` / `.sh` — author verification + write access | Runs `delete_modpack.bat` / `.sh` — author verification + **write access required** |

The upload scripts handle Git setup, GitHub authentication (via `gh` CLI or personal access token), cloning the repo, and pushing changes.

### mod.json Reference

```json
{
  "name": "My Mod",
  "id": "my_mod",
  "version": "1.0.0",
  "author": "YourGitHubUsername",
  "description": "A short description of what this mod does.",
  "tags": ["Gameplay", "QoL"],
  "dependencies": [
    { "id": "other_mod", "min_version": "1.0.0" }
  ],
  "incompatible": ["conflicting_mod"],
  "settings": [
    {
      "key": "difficulty",
      "label": "Difficulty",
      "type": "int",
      "default": 5,
      "min": 1,
      "max": 10
    }
  ],
  "scripts": ["main.rb"],
  "icon": "icon.png"
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Display name |
| `id` | Yes | Unique identifier (lowercase, underscores) |
| `version` | Yes | Semantic version (`X.Y.Z`) |
| `author` | Yes | Your GitHub username |
| `description` | No | Short description shown in the browser |
| `tags` | No | Array of tags for filtering |
| `dependencies` | No | Array of `{ "id", "min_version" }` objects |
| `incompatible` | No | Array of mod IDs this mod conflicts with |
| `settings` | No | Array of setting definitions (see below) |
| `scripts` | Yes | Array of `.rb` files to load (in order) |
| `icon` | No | Filename of the icon image (shown in browser) |

### modpack.json Reference

```json
{
  "name": "Competitive Pack",
  "id": "competitive_pack",
  "version": "1.0.0",
  "author": "YourGitHubUsername",
  "description": "A curated set of mods for competitive play.",
  "tags": ["Gameplay", "Balance"],
  "mods": [
    { "id": "auto_ev_trainer", "version": "1.2.0" },
    { "id": "damage_calc_overlay" }
  ]
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Display name |
| `id` | Yes | Unique identifier |
| `version` | Yes | Semantic version |
| `author` | Yes | Your GitHub username |
| `description` | No | Short description |
| `tags` | No | Array of tags |
| `mods` | Yes | Array of `{ "id", "version" }` — `version` is an optional minimum |

### Settings Definitions

Mods can define settings in `mod.json` that players can configure from the UI:

```json
"settings": [
  {
    "key": "enabled",
    "label": "Enable Feature",
    "type": "bool",
    "default": true
  },
  {
    "key": "speed",
    "label": "Speed Multiplier",
    "type": "float",
    "default": 1.5,
    "min": 0.5,
    "max": 5.0
  },
  {
    "key": "mode",
    "label": "Game Mode",
    "type": "string",
    "default": "normal",
    "options": ["easy", "normal", "hard"]
  }
]
```

| Type | Fields | Description |
|------|--------|-------------|
| `bool` | `key`, `label`, `default` | Toggle (true/false) |
| `int` | `key`, `label`, `default`, `min`, `max` | Integer slider |
| `float` | `key`, `label`, `default`, `min`, `max` | Decimal slider |
| `string` | `key`, `label`, `default`, `options` | Selection from a list |

Access at runtime: `$mod_manager_settings["my_mod"]["speed"]`

### Tags

Available tags for mods and modpacks:

`Gameplay` · `Visual` · `Audio` · `QoL` · `Content` · `Fusion` · `Balance` · `Debug` · `Multiplayer`

### Repository Structure

```
KIF-Mods/mods/
├── my_mod/
│   ├── mod.json
│   ├── main.rb
│   └── icon.png
├── another_mod/
│   ├── mod.json
│   └── main.rb
└── modpacks/
    └── competitive_pack/
        └── modpack.json
```

### Mod File Structure (Local)

```
Game Root/
├── Mods/                    # Installed mods (downloaded by Mod Manager)
│   ├── my_mod/
│   │   ├── mod.json
│   │   └── main.rb
│   └── .mod_browser_enabled # Marker file enabling the Mod Browser
├── ModDev/                  # Development folder (your mods in progress)
│   ├── my_mod/
│   │   ├── mod.json
│   │   └── main.rb
│   ├── publish_mod.bat      # Upload script (Windows)
│   ├── publish_mod.sh       # Upload script (Mac/Linux)
│   ├── publish_modpack.bat
│   ├── publish_modpack.sh
│   ├── delete_mod.bat
│   ├── delete_mod.sh
│   ├── delete_modpack.bat
│   └── delete_modpack.sh
└── Data/Scripts/998_ModManager/
    ├── 001_ModData.rb       # Core data layer
    ├── 001b_MMVersion.rb    # Mod Manager version
    ├── 002_ModLoader.rb     # Boot-time mod loader
    ├── 003_ModManagerUI.rb  # Installed mods UI
    ├── 004_ModBrowser.rb    # Browser, GitHub API, tabs, progress overlay
    ├── 005_ModSettings.rb   # Settings UI
    ├── 006_ModderTools.rb   # Modder tools (create/update/upload/delete)
    └── 007_TitleHook.rb     # Title screen integration
```

---

<p align="center">
  <i>Part of Kuray's Infinite Fusion — made by the community, for the community.</i>
</p>
