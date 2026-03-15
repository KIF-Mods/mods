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
6. Publish using **Modder Tools** > **Upload Mod** (or run `publish_mod.bat` / `publish_mod.sh` directly)

You can also use:
- **Update Mod** — edit any field (name, version, tags, dependencies, etc.)
- **Upload Mod** — opens the publisher script to push your mod to GitHub
- **Delete Mod** — remove a mod from `ModDev/`

### Option B: Manual Setup

If you prefer to set things up yourself:

1. Create a folder named after your mod ID (lowercase, underscores only — e.g. `my_cool_mod`)
2. Create a `mod.json` file inside it (see [mod.json format](#modjson-format) below)
3. Create your `.rb` script files
4. Upload the folder to this repo

#### Folder structure

```
your_mod_id/
  mod.json          # Required - mod metadata
  main.rb           # Your mod code
  icon.png          # Optional - 32x32 icon
```

You can organize your code however you like — **all `.rb` files are auto-detected**, including in subfolders:

```
my_big_mod/
  mod.json
  main.rb
  battle/
    moves.rb
    abilities.rb
  ui/
    overlay.rb
    menu.rb
  items.rb
  pokemon.rb
```

All `.rb` files load automatically in alphabetical order. If you need a specific load order, list them in `mod.json` (see below).

---

## Script Loading

By default, the mod loader **auto-detects all `.rb` files** in your mod folder and subfolders. They load in alphabetical order.

If you need scripts to load in a specific order (e.g. a base file before files that depend on it), list them explicitly in `mod.json`:

```json
"scripts": ["core.rb", "battle/moves.rb", "battle/abilities.rb", "ui/overlay.rb"]
```

If `"scripts"` is empty (`[]`) or omitted, all `.rb` files are auto-detected. Most mods won't need to worry about this.

---

## Publishing Your Mod

### From In-Game (Easiest)

1. Open the game
2. **Mod Manager** > **Modder Tools** > **Upload Mod**
3. A terminal window opens with the publisher script
4. Follow the prompts — it handles Git setup, authentication, and pushing

### From Your Desktop

Double-click the publish script in your `ModDev/` folder:

| Platform | Script |
|----------|--------|
| Windows | `publish_mod.bat` |
| Mac/Linux | `publish_mod.sh` |

### What the publisher does

1. **Checks for Git** — installs it if needed (Windows: winget, Mac: Homebrew, Linux: apt/dnf/pacman)
2. **GitHub authentication** — uses GitHub CLI (`gh auth login`) for easy browser-based login. Installs `gh` if needed, or falls back to Personal Access Token
3. **Checks your access level** — tells you upfront if you have write access or if you'll need a Pull Request
4. **Syncs, copies, commits, and pushes** your mod

### Use Case 1: Publishing a New Mod

```
1. Create your mod in-game (Modder Tools > Create Mod)
2. Edit your .rb files with your code
3. Modder Tools > Upload Mod (or run publish_mod.bat)
4. Follow the prompts
5. Players can now see and install it from the in-game Mod Browser
```

### Use Case 2: Updating an Existing Mod

```
1. Edit your code in ModDev/your_mod_id/
2. Bump the version (Modder Tools > Update Mod > Version)
3. Upload Mod (or run publish_mod.bat)
4. It detects changes and pushes the update
5. Players see "UPD" next to your mod in the Mod Browser
```

### Use Case 3: Full Modder Workflow

```
Day 1 — Create
  - Open game > Mod Manager > Modder Tools > Create Mod
  - Fill in: name, author, description, tags
  - Edit main.rb with your code
  - Modder Tools > Upload Mod to push v1.0.0

Day 2 — Bug fix
  - Fix the bug in main.rb
  - Modder Tools > Update Mod > Version > change to 1.0.1
  - Upload Mod — pushes the update

Day 5 — Growing bigger
  - Add more script files (battle.rb, ui.rb, etc.)
  - They're auto-detected, no need to update mod.json
  - Organize into subfolders if you want
  - Bump version to 1.1.0, Upload Mod

Later — Add dependency
  - Your mod now needs "some_other_mod" to work
  - Modder Tools > Update Mod > Dependencies > pick from list
  - Bump version, Upload Mod
  - Players who install your mod will see the dependency warning
```

### Without Write Access

If you don't have write access to this repo, the publisher will tell you and offer two options:

1. **Ask for access** — ask a KIF-Mods admin to add you to the [Modders team](https://github.com/orgs/KIF-Mods/teams/modders), then run the script again
2. **Fork and Pull Request** — fork this repo, upload your mod folder, and open a PR. An admin will review and merge it

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
  "scripts": []
}
```

All fields are required. `dependencies`, `incompatible`, `settings`, and `scripts` can be empty arrays.

> **Note:** When `"scripts"` is empty, all `.rb` files in your mod folder (and subfolders) are auto-detected and loaded alphabetically. Only fill this in if you need a specific load order.

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

When adding these via the in-game Modder Tools, you can pick from a list of all known mods (installed, in development, and from this repo) instead of typing IDs manually.

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
