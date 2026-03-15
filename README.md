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
6. Publish using `publish_mod.bat` (see below)

You can also use **Modder Tools** > **Update Mod** to edit any field later, and **Delete Mod** to remove a mod from `ModDev/`.

### Option B: Manual Setup

If you prefer to set things up yourself:

1. Create a folder named after your mod ID (lowercase, underscores only — e.g. `my_cool_mod`)
2. Create a `mod.json` file inside it (see [mod.json format](#modjson-format) below)
3. Create a `main.rb` file with your mod code
4. Upload the folder to this repo

#### Folder structure

```
your_mod_id/
  mod.json        # Required - mod metadata
  main.rb         # Required - main script
  icon.png        # Optional - 32x32 icon
  other_file.rb   # Optional - additional scripts
```

---

## Publishing Your Mod

### Using publish_mod.bat (Recommended)

A `publish_mod.bat` script is included in your `ModDev/` folder. It handles everything automatically.

**Requirements:** [Git](https://git-scm.com/downloads) must be installed (select "Add to PATH" during setup).

Just double-click `publish_mod.bat`, pick your mod, and it pushes to GitHub.

### Use Case 1: Publishing a New Mod

```
1. Create your mod in-game (Modder Tools > Create Mod)
2. Edit ModDev/your_mod_id/main.rb with your code
3. Double-click publish_mod.bat
4. Select your mod from the list
5. Confirm — it gets pushed to GitHub
6. Players can now see and install it from the in-game Mod Browser
```

### Use Case 2: Updating an Existing Mod

```
1. Edit your mod's code in ModDev/your_mod_id/
2. Update the version in mod.json (in-game: Modder Tools > Update Mod > Version)
3. Double-click publish_mod.bat
4. Select your mod — it detects changes and pushes the update
5. Players will see "UPD" next to your mod in the Mod Browser
```

### Use Case 3: Full Modder Workflow

```
Day 1 — Create
  - Open game > Mod Manager > Modder Tools > Create Mod
  - Fill in: name, author, description, tags
  - Edit ModDev/my_mod/main.rb with your code
  - Run publish_mod.bat to push v1.0.0

Day 2 — Bug fix
  - Fix the bug in main.rb
  - In-game: Modder Tools > Update Mod > Version > change to 1.0.1
  - Run publish_mod.bat — pushes the update

Day 5 — Add settings
  - In-game: Modder Tools > Update Mod > add settings/tags/dependencies
  - Update main.rb to use the new settings
  - Bump version to 1.1.0
  - Run publish_mod.bat

Later — Add dependency
  - Your mod now needs "some_other_mod" to work
  - In-game: Modder Tools > Update Mod > Dependencies > pick from list
  - Bump version, run publish_mod.bat
  - Players who install your mod will see the dependency warning
```

### Manual Upload (No Script)

If you don't want to use the script:

- Fork this repo on GitHub
- Add/update your mod folder
- Open a Pull Request

Or if you have write access, push directly.

---

## mod.json Format

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

### Settings (optional)

If your mod has configurable options, players can change these in-game via the Mod Manager.

| Type | Example |
|------|---------|
| Toggle | `{ "type": "toggle", "key": "enable_feature", "label": "Enable Feature", "default": true }` |
| Enum | `{ "type": "enum", "key": "difficulty", "label": "Difficulty", "options": ["Easy", "Normal", "Hard"], "default": 1 }` |
| Slider | `{ "type": "slider", "key": "speed", "label": "Speed", "min": 1, "max": 100, "default": 50 }` |
| Number | `{ "type": "number", "key": "max_items", "label": "Max Items", "min": 1, "max": 999, "default": 99 }` |

### Dependencies and Incompatibilities

```json
"dependencies": [
  { "id": "other_mod_id", "min_version": "1.0.0" }
],
"incompatible": ["conflicting_mod_id"]
```

When adding these via the in-game Modder Tools, you can pick from a list of all known mods instead of typing IDs manually.

### Valid Tags

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
