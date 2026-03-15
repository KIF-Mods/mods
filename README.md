# KIF Mods Repository

This is the official mod repository for **KIF Multiplayer** (Kuray's Infinite Fusion). Mods listed here appear in the in-game **Mod Browser** for all players.

---

## Creating a Mod

### Option A: In-Game (Recommended)

The easiest way to create a mod is through the in-game tools:

1. Open the game and go to **Mod Manager** on the title screen
2. Click **Modder Tools** > **Create Mod**
3. Fill in the prompted fields (name, author, description, version, tags, etc.)
4. Your mod folder is automatically generated in `ModDev/your_mod_id/` with a ready-to-use `mod.json` and `main.rb` template
5. Edit `main.rb` with your mod code
6. Upload the folder to this repo (see [Uploading Your Mod](#uploading-your-mod) below)

You can also use **Modder Tools** > **Update Mod** to edit any field later, and **Delete Mod** to remove a mod from `ModDev/`.

### Option B: Manual Setup

If you prefer to set things up yourself:

1. Create a folder in this repo named after your mod ID (lowercase, underscores only — e.g. `my_cool_mod`)
2. Create a `mod.json` file inside it (see format below)
3. Create a `main.rb` file with your mod code

#### Folder structure

```
your_mod_id/
  mod.json        # Required - mod metadata
  main.rb         # Required - main script
  icon.png        # Optional - 32x32 icon
  other_file.rb   # Optional - additional scripts
```

#### mod.json format

```json
{
  "name": "My Cool Mod",
  "id": "my_cool_mod",
  "version": "1.0.0",
  "author": "YourName",
  "description": "A short description of what your mod does.",
  "tags": ["Gameplay", "QoL"],
  "dependencies": [],
  "incompatible": [],
  "settings": [],
  "scripts": ["main.rb"]
}
```

All fields are required. `dependencies`, `incompatible`, and `settings` can be empty arrays.

#### Settings (optional)

If your mod has configurable options, add them to the `settings` array. Players can change these in-game via the Mod Manager.

```json
"settings": [
  { "type": "toggle", "key": "enable_feature", "label": "Enable Feature", "default": true },
  { "type": "enum", "key": "difficulty", "label": "Difficulty", "options": ["Easy", "Normal", "Hard"], "default": 1 },
  { "type": "slider", "key": "speed", "label": "Speed", "min": 1, "max": 100, "default": 50 },
  { "type": "number", "key": "max_items", "label": "Max Items", "min": 1, "max": 999, "default": 99 }
]
```

#### Dependencies and Incompatibilities

```json
"dependencies": [
  { "id": "other_mod_id", "min_version": "1.0.0" }
],
"incompatible": ["conflicting_mod_id"]
```

When adding these via the in-game Modder Tools, you can pick from a list of all known mods (installed, in development, and from this repo) instead of typing IDs manually.

---

## Uploading Your Mod

- Fork this repo
- Add your mod folder (the one from `ModDev/`)
- Open a Pull Request

Or if you have direct write access, push your folder directly.

**Updating your mod:** Change the `version` field in `mod.json` and push the updated files. Players will see an update notification in the Mod Browser.

---

## Valid Tags

`Gameplay`, `Visual`, `Audio`, `QoL`, `Balance`, `Difficulty`, `Fusion`, `Multiplayer`, `UI`, `Cosmetic`, `Bug Fix`, `Content`

---

## Accessing Mod Settings in Your Code

```ruby
# Your mod's settings are available via:
settings = $mod_manager_settings["your_mod_id"]

# Example:
if settings["enable_feature"]
  # do something
end

speed = settings["speed"] || 50
```

---

## For Players

Mods from this repo appear in the in-game **Mod Browser** (title screen > Mod Manager > Mod Browser). You can browse, install, update, enable/disable, and configure mods directly from there.
