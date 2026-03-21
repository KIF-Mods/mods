<p align="center">
  <img src="https://img.shields.io/badge/KIF-Kuray's%20Infinite%20Fusion-purple?style=for-the-badge" alt="KIF">
  <img src="https://img.shields.io/badge/Multiplayer-v6.4.0-blue?style=for-the-badge" alt="Multiplayer v6.4.0">
  <img src="https://img.shields.io/badge/Mod%20Manager-v1.0.0-green?style=for-the-badge" alt="Mod Manager v1.0.0">
</p>

> **Sprite servers are currently down.** If you're seeing white question marks instead of sprites, download the pre-loaded version from [MediaFire](https://www.mediafire.com/folder/eo2b1qmi5ukyd/Kuray_Infinite_Fusion).

---

# Kuray's Infinite Fusion (KIF)

**Kuray's Infinite Fusion (KIF)** is a community-driven fork of Pokemon Infinite Fusion that adds multiplayer, mod support, a powerful AI, infinite shiny colors, and much more.

KIF is **standalone** — you do **not** need Pokemon Infinite Fusion (PIF), and you should **not** install KIF on top of a PIF game.

> The backbone of KIF (PIF) is still maintained by Chardub/Frogman. If PIF dies, KIF is very likely to follow.

---

## Table of Contents

- [Official Links](#official-links)
- [Installation](#installation)
- [Mod Manager](#mod-manager)
- [Features — Always On](#features--always-on)
- [Features — Configurable](#features--configurable)
- [Modding](#modding)
- [Credits & Contributors](#credits--contributors)

---

## Official Links

| Platform | Link |
|----------|------|
| Website | https://www.kurayinfinitefusion.com/ |
| Discord | [Kuray Hub](https://discord.gg/kuray-hub-1121345297352753243) · [Invite](https://discord.gg/vZUCRxDTPe) |
| Twitter / X | https://twitter.com/kuray_hub |
| Reddit | https://www.reddit.com/r/kurayhub/ |
| GitHub | https://github.com/kurayamiblackheart/kurayshinyrevamp |
| YouTube | https://www.youtube.com/@kuraylab |
| Twitch | https://www.twitch.tv/kurayamiblackheart |

**Related projects:**

| Project | Link |
|---------|------|
| Pokemon Infinite Fusion (PIF) | [GitHub](https://github.com/infinitefusion/infinitefusion-e18) · [Discord](https://discord.gg/infinitefusion) |
| Pokemon Essentials | [GitHub](https://github.com/Maruno17/pokemon-essentials) |

> Banned from the Kuray Hub Discord? [Fill this form](https://forms.gle/TPCprf38ANmYNB5T8) to request an unban or get info about your ban.

---

## Installation

1. Go to **Releases** and download the latest release (Source Code.zip), or use this direct link:
   https://github.com/kurayamiblackheart/kurayshinyrevamp/archive/refs/heads/release.zip

2. Text instructions are available on the Discord: https://discord.gg/UFxQkUZeyE

> **Google Docs** (obsolete, but some info is still useful): [Link](https://docs.google.com/document/d/1O6pKKL62dbLcapO0c2zDG2UI-eN6uatYlt_0GSk1dbE/edit)

---

## Mod Manager

KIF includes a built-in **Mod Manager** that lets players browse, install, update, and manage mods entirely from within the game — no manual file copying needed.

### For Players

- **Mod Browser** — Browse all mods hosted on the [KIF-Mods](https://github.com/KIF-Mods/mods) GitHub repository. See mod names, descriptions, tags, versions, and install status at a glance.
- **One-Click Install & Update** — Install or update any mod with a single button press. The Mod Manager downloads all files automatically.
- **Modpacks** — Curated collections of mods that can be installed together in one go. Browse modpacks in the dedicated **Modpacks** tab.
- **Auto-Dependencies** — When installing a mod that requires other mods, the Mod Manager detects and offers to download them automatically.
- **Share Codes** — Generate a compact code (`KIF-...`) representing your enabled mods. Share it with friends on Discord, and they can paste it in-game to install the same set of mods instantly.
- **Settings** — Many mods expose in-game settings (toggles, sliders, selections) that you can configure from the Mod Manager without editing files.
- **Enable / Disable** — Toggle mods on and off without uninstalling them.
- **Self-Update** — The Mod Manager checks for its own updates and can update itself in-game.

### For Modders

- **Modder Tools** — Built-in tools for creating, updating, uploading, and deleting mods and modpacks, all from within the game.
- **Create Mod** — A guided wizard that generates a `mod.json` manifest and `main.rb` template in the `ModDev/` folder.
- **Create Modpack** — Select any combination of mods, set optional minimum versions, and generate a `modpack.json`.
- **Upload to GitHub** — Publish your mod or modpack to the KIF-Mods repo directly from the game via included scripts (`publish_mod.bat` / `publish_modpack.bat`). Modpacks require verified team write access.
- **Dependencies & Incompatibilities** — Declare which mods yours depends on or conflicts with in `mod.json`.
- **Settings Definitions** — Define custom settings (booleans, integers, floats, string selections) in your `mod.json` so players can configure your mod from the UI.
- **Tags** — Tag your mods (Gameplay, Visual, Audio, QoL, Content, Fusion, Balance, Debug, Multiplayer) for filtering.

### Mod Structure

Mods live in the `Mods/` folder. Each mod has its own subfolder containing:

```
Mods/
└── my_mod/
    ├── mod.json       # Manifest (name, id, version, author, tags, dependencies, settings, scripts)
    ├── main.rb        # Entry point (loaded by the Mod Manager)
    ├── icon.png       # Optional icon displayed in the browser
    └── ...            # Additional scripts, assets, etc.
```

Mods are loaded at boot in alphabetical order. Access your mod's settings at runtime via `$mod_manager_settings["my_mod"]`.

---

## Features — Always On

These features are always active in KIF:

| Feature | Credit |
|---------|--------|
| Modding support | DemICE |
| Game speed up to **x10**, displayed on title bar | Reïzod |
| No double-confirmation for unfusing | Reïzod |
| Revamped gender icons | Reïzod |
| IV/EVs shown in Pokemon Summary | Luminatron |
| Pokemon can relearn pre-evolution moves | Reïzod |
| Quick Surf → Quick Field Moves | Reïzod |
| 161 additional PC backgrounds | Reïzod |
| Transgender stone works with genderless, male, and female | Reïzod |
| Endgame challenge & powerful AI — opponents fight for real | DemICE |
| Infinite save files — new backup at each save | DemICE |
| Custom fusion icon support | Reïzod |
| Self-Battle — battle your own Pokemon from PC / "Battlers" folder / team | Reïzod, TrapStarr & DemICE |
| Shiny Finder.exe — quickly preview all shiny possibilities of a sprite | Reïzod |
| Auto-updater — checks for updates on launch and installs automatically | HungryPickle |
| Breed fused Pokemon (KIF-exclusive, was removed from PIF 6.0) | Reïzod |
| Sprite downloader — install all autogen + custom sprites locally (~200k sprites) | Reïzod |
| Mystery Gift — distributions announced on Discord | Reïzod |
| Many PIF bug patches for improved stability | — |

> **Sprite sources:** [Autogen](https://gitlab.com/pokemoninfinitefusion/autogen-fusion-sprites) · [Custom](https://gitlab.com/pokemoninfinitefusion/customsprites)

---

## Features — Configurable

These features can be toggled on/off or customized in the options:

| Feature | Credit |
|---------|--------|
| Shiny animations toggle | Reïzod |
| **Shiny Revamp** — channel + hue shifting with up to **37,964,160,000** combinations. Three modes: 360 / 622,080 / 37B+ shinies | Reïzod |
| 1v1 / 2v2 / 3v3 wild battles | Reïzod |
| 1v1 / 2v2 / 3v3 trainer battles | Reïzod |
| Shiny icons | Reïzod |
| Export / Import Pokemon (to/from `.json` & `.png`, including shiny sprites) | Reïzod |
| Lock evolution (prevent evolving until manually unlocked) | Reïzod |
| Choose / re-roll shiny colors (DEBUG only) | Reïzod |
| Shiny dye fusing | JustAnotherU5er |
| Shiny preview on fusions (no black/green silhouettes) | Reïzod |
| **Robust level caps** — Smart Exp, Locked Exp, or Rare Candies on cap | Reïzod & HungryPickle |
| Buy infinite PC boxes | Reïzod |
| Gamble to make Pokemon shiny / change shiny colors | Reïzod |
| Sort Pokemon in PC (by name, dex #, level, stats, IVs, EVs, type, nature, ability, and more) | Reïzod |
| Multi-select in PC | Sylvi |
| Change game font | Reïzod |
| Pokemon sprites as icons (in team and PC boxes) | Sylvi |
| Individual custom sprites (two of the same species can look different) | Reïzod |
| Kuray Shop (rare candies, master balls, stones, and more) | Reïzod |
| Dynamic self-fusion stat boosts (weaker Pokemon get bigger boosts) | Reïzod |
| PC & instant heal from menu | Reïzod |
| Change shiny odds from options | Reïzod |
| Pokemon added to Pokedex when catching/evolving fusions | TrapStarr |
| Consumable items recovered after battle | TrapStarr |
| Configurable Exp All redistribution | HungryPickle |
| Type icons in battle (multiple icon sets) | TrapStarr, Mirasein & FairyGodMother |
| Auto-Battle (with shortcut toggle and shiny-stop option) | Reïzod & TrapStarr |
| Trainers use shinies (configurable: always, ace only, or never) | TrapStarr |
| Damage variance toggle | DemICE |
| Unfuse traded Pokemon option | Reïzod |
| Quicksave | DemICE |
| Dark battle GUI & multiple battle GUIs | TrapStarr & Mirasein |
| Toggle sprite selection in Pokedex on catch | Reïzod |
| Toggle nickname prompt | Reïzod |
| Toggle team/PC prompt for new Pokemon | Reïzod |
| Skip intro cutscene | Reïzod |
| Decompile / recompile game database (DEBUG — use with caution) | Reïzod |
| Breed legendaries if head in fusion (KIF-exclusive) | Reïzod |
| Poison overworld config (ability-based immunity / healing) | BlueWuppo |
| Modern Hail | BlueWuppo |
| Bug-type buff | BlueWuppo |
| Ice-type buff | BlueWuppo |
| Frostbite instead of Frozen | BlueWuppo |
| Drowsy instead of Asleep | BlueWuppo |
| Event moves added to Battle Factory egg move tutor | HungryPickle & Rekt1029 |
| Dominant typing for fusions (KIF-exclusive, was in PIF pre-6.0) | DemICE |
| Adjustable base stat spread for fused Pokemon | HungryPickle |
| Tutor.net — all TMs and move tutors in one menu | DemICE |
| Metronome Madness challenge (force Metronome) | Reïzod |
| Letdown challenge (random Splash) | Reïzod |
| Berserker challenge (enemy stats rise) | Reïzod |
| Speed-up mode: toggle vs hold | Reïzod |
| Shiny cache system (performance boost, `.png` access in Cache folder) | Reïzod |
| Options presets — save and load game configurations | Reïzod |
| Exempt PC boxes from Sort All / Export All | Reïzod |
| No-EVs Mode (non-destructive, applies to all Pokemon) | Reïzod |
| Max IVs Mode (non-destructive, forces 31 IVs in calculations) | Reïzod |
| Show levels in No Level / Base Stats Mode | Reïzod |
| Rocket Mode — catch trainers' Pokemon (Rocket Ball or all balls) | Reïzod |
| Trainer Exp boost modifier (default +50%, adjustable) | Reïzod |
| EVs Train Mode — enemies yield no EVs, only Power items do | Reïzod |
| K-Eggs — random Pokemon from type-themed eggs, 10x shiny chance, rarity based on catch rate | Reïzod |

---

## Modding

### Creating a Mod

1. Open the **Mod Manager** in-game (from the title screen)
2. Go to **Modder Tools** → **Create** → **Mod**
3. Follow the wizard: name, author, description, version, tags, dependencies
4. Your mod is generated in `ModDev/<mod_id>/` with a `mod.json` and `main.rb`
5. Write your code in `main.rb` (or add more scripts and list them in `mod.json`)
6. Test by copying the folder to `Mods/` and launching the game
7. Upload via **Modder Tools** → **Upload** → **Mod** (runs `publish_mod.bat`)

### Creating a Modpack

1. **Modder Tools** → **Create** → **Modpack**
2. Pick the mods to include, set optional minimum versions
3. Generated in `ModDev/<pack_id>/modpack.json`
4. Upload via **Upload** → **Modpack** (requires verified team write access)

### mod.json Reference

```json
{
  "name": "My Mod",
  "id": "my_mod",
  "version": "1.0.0",
  "author": "YourName",
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

### modpack.json Reference

```json
{
  "name": "Competitive Pack",
  "id": "competitive_pack",
  "version": "1.0.0",
  "author": "YourName",
  "description": "A curated set of mods for competitive play.",
  "tags": ["Gameplay", "Balance"],
  "mods": [
    { "id": "auto_ev_trainer", "version": "1.2.0" },
    { "id": "damage_calc_overlay" }
  ]
}
```

### Mod Repository

All community mods are hosted at [**KIF-Mods/mods**](https://github.com/KIF-Mods/mods):

```
KIF-Mods/mods/
├── my_mod/
│   ├── mod.json
│   ├── main.rb
│   └── icon.png
├── another_mod/
│   └── mod.json
└── modpacks/
    └── competitive_pack/
        └── modpack.json
```

---

## Credits & Contributors

KIF is made by the community, for the community.

| Contributor | Contributions |
|-------------|--------------|
| **Chardub / Frogman** | Original Pokemon Infinite Fusion |
| **Reïzod** | KIF founder — shiny revamp, mod system, QoL features, challenges, K-Eggs, and dozens more |
| **DemICE** | Modding support, powerful AI, quicksave, save system, tutor.net, stat spread |
| **TrapStarr** | Self-battle, auto-battle, type icons, trainer shinies, Pokedex on catch |
| **Sylvi** | Multi-select in PC, sprites as icons |
| **HungryPickle** | Auto-updater, level caps, Exp All config, stat spread, event moves |
| **sKarreku** | Multiplayer, Mod Manager, Aleks Full Implementation (NPT) |
| **Luminatron** | IV/EVs in summary |
| **Mirasein** | Battle GUI themes, type icons |
| **FairyGodMother** | Type icon sets |
| **BlueWuppo** | Poison config, modern hail, type buffs, frostbite, drowsy |
| **JustAnotherU5er** | Shiny dye fusing |
| **Rekt1029** | Event moves in Battle Factory |

---

<p align="center">
  <i>This is an open-source project. Contributions via pull requests are welcome.</i>
</p>
