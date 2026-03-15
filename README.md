# KIF Mods Repository

This is the official mod repository for **KIF Multiplayer** (Kuray's Infinite Fusion). Mods listed here appear in the in-game **Mod Browser**.

## How to Upload Your Mod

### 1. Create your mod in-game
Use **Mod Manager > Modder Tools > Create Mod** to generate your mod folder in `ModDev/`.

### 2. Folder structure
Each mod is a folder at the root of this repo. Your folder **must** contain a `mod.json` and at least one script file.

```
your_mod_id/
  mod.json        # Required - mod metadata
  main.rb         # Required - main script
  icon.png        # Optional - 32x32 icon
  other_file.rb   # Optional - additional scripts
```

### 3. mod.json format

```json
{
  "name": "My Cool Mod",
  "id": "my_cool_mod",
  "version": "1.0.0",
  "author": "YourName",
  "description": "A short description of what your mod does.",
  "tags": ["Gameplay", "QoL"],
  "dependencies": [
    { "id": "some_other_mod", "min_version": "1.0.0" }
  ],
  "incompatible": ["conflicting_mod_id"],
  "settings": [
    { "type": "toggle", "key": "enable_feature", "label": "Enable Feature", "default": true },
    { "type": "enum", "key": "difficulty", "label": "Difficulty", "options": ["Easy", "Normal", "Hard"], "default": 1 },
    { "type": "slider", "key": "speed", "label": "Speed", "min": 1, "max": 100, "default": 50 },
    { "type": "number", "key": "max_items", "label": "Max Items", "min": 1, "max": 999, "default": 99 }
  ],
  "scripts": ["main.rb"]
}
```

### 4. Valid tags
`Gameplay`, `Visual`, `Audio`, `QoL`, `Balance`, `Difficulty`, `Fusion`, `Multiplayer`, `UI`, `Cosmetic`, `Bug Fix`, `Content`

### 5. Upload
- Fork this repo
- Add your mod folder
- Open a Pull Request

Or if you have write access, push directly.

### 6. Accessing mod settings in your code

```ruby
# Your mod's settings are available via:
settings = $mod_manager_settings["your_mod_id"]

# Example:
if settings["enable_feature"]
  # do something
end

speed = settings["speed"] || 50
```

## For Players

Mods from this repo appear in the in-game **Mod Browser** (Mod Manager > Mod Browser). You can install, update, enable/disable mods directly from there.
