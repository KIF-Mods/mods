══════════════════════════════════════════════
KANTO RELOADED
Update #2 - Wild Link & Double Abilities
v1.3.0
Release Date: July 26, 2026
══════════════════════════════════════════════

SUMMARY
-------
This update adds Wild Link, Double Abilities, Move Effectiveness colors and live ability randomization while expanding battle interface customization and existing quality-of-life systems.

FEATURES
--------
• Added live Dynamic Ability randomization for newly generated Pokemon, trainer parties, fusions, reversals, and unfusions
• Added an optional Double Abilities system for newly created, generated, and reversed fusion Pokemon while keeping single-species Pokemon limited to one ability
• Added compatible two-ability behavior for reviewed abilities, moves, and effects, including Transform, Trace, Skill Swap, Role Play, Entrainment, Mummy, Lingering Aroma, Wandering Spirit, Scrappy, Aerilate, Stance Change, Disguise, Schooling, Power Construct, Shields Down, Battle Bond, Zen Mode, Neutralizing Gas, Slow Start, Multitype, and RKS System
• Added descriptive, slot-aware ability selection for fusion creation, Summary, Ability Capsule, Secret Capsule, Ability Ball
• Added Double Abilities-aware AI scoring for ability-changing moves and secondary Illusion support in opponent switch previews
• Added Wild Link, a targeted overworld Pokemon search system for Land, Cave, Surf, Fishing, Headbutt, and Rock Smash encounters
• Added permanent per-species and per-fusion Search Levels, method-and-map chains, post-battle continuation modes, and progressive target information
• Added Wild Link bonuses for shiny rolls, perfect IVs, Hidden Abilities, up to two Egg Moves, native held items, and encounter levels
• Added Hoenn-style Wild Link overworld reactions, temperament movement, and staged flee animations

IMPROVEMENTS
------------
• Expanded Dynamic Pokemon to reroll eligible Gift Pokemon and Static Encounters when their corresponding KIF randomizer toggles are enabled
• Generalized signature abilities that do not require form changes, including Dondozo-gated Commander, modern Battle Bond boosts, and held-item typing for Multitype and RKS System

BALANCE
-------
• Improved Reloaded Shop bulk purchases to award one Premier Ball per 10 Poke Balls and one DNA Reverser per 10 DNA Splicers
• Restricted form-dependent abilities to native species or fusion components, with a 25% native roll and a 75% general roll for eligible owners
• Limited Wonder Guard to three blocked damaging moves per battle when paired with a second active ability or assigned by Dynamic Abilities

BUG FIXES
---------
• Fixed Battle Menu, Overworld Menu, and Egg Manager stack overflows on JoiPlay
• Fixed Settings Preset saving on JoiPlay and included registered Kanto Reloaded settings in preset save and load
• Fixed uploaded bug-report links not copying to the clipboard on supported JoiPlay runtimes
• Fixed enlarged EBDX move buttons rendering beneath neighboring move buttons
• Fixed EBDX multi-target selection showing DNA placeholders instead of Pokemon icons
• Fixed Overworld Menu status text being compressed when its command label left enough unused row space

VISUALS & UI
------------
• Improved read-only option rows with dimmed theme colors, cursor navigation, and accessible descriptions without allowing edits
• Added optional Move Effectiveness borders for native and EBDX move and target selection, with configurable neutral, 4x, 2x, x1/2, and x1/4 colors
• Added an optional Reloaded EBDX Cursor for rounded command, move, target, and battle-bag selection borders

TECHNICAL
---------
• Added guarded signature-ability adapters that preserve native handlers while extending compatible mechanics to randomized holders
• Preserved Dynamic Ability assignment and randomized Wonder Guard charge metadata through Pokemon JSON export and import
• Added guarded Double Abilities dispatch across all 46 KIF ability-handler entry points, standard Pokemon ability predicates, and reviewed direct-check mechanics with correct secondary ability splash names and without replacing KIF, Multiplayer, or Family Pokemon files
• Added versioned per-Pokemon Double Abilities metadata without backfilling existing fusion Pokemon
• Added guarded Wild Link bridges that preserve native field interactions, pass exact generated Pokemon into wild battles, and suppress only step encounters while a target is active

DEVELOPER
---------
• Added the stable `KantoReloaded::DoubleAbilities` API contract and documented its ability, item, compatibility, and blacklist behavior


══════════════════════════════════════════════
KANTO RELOADED
Update #1 - Reloaded PC
v1.2.0
Release Date: July 23, 2026
══════════════════════════════════════════════

SUMMARY
-------
This update adds dynamic randomization, save management, and a Reloaded PC interface while improving existing QoL systems.

FEATURES
--------
• Added a Randomizer module with per-encounter wild Pokemon and per-pickup item randomization
• Added Wild Selection for switching between BST-matched and fully random encounters
• Added a Reloaded PC toggle with Reloaded-only animation, speed, and Pokemon art settings
• Added Reloaded PC Speed with Off, 2x, and 3x modes. Speed-Up button is disabled in the RLD PC.
• Added Reloaded PC controls with L/R box switching, X-button focus cycling, A-button Normal, Quick Swap, and Multi Select modes, and a Z-button Reloaded PC menu
• Added a Big Icons option for switching between icons and full sprites
• Added Reloaded PC mouse controls with click-or-drag Quick Swap pickup, carry-aware box-panel wheel navigation, clickable footer controls and adjacent-box headers, drag-hover box switching, drag-and-drop moving or swapping, and right-click action menus
• Added EBDX-compatible reverse fusion support
• Added Save Manager for safely archiving, restoring, inspecting, and permanently removing save files

IMPROVEMENTS
------------
• Updated the About screen and framework services to read Kanto Reloaded's version directly from `mod.json`
• Changed TM Vault's Relearn Moves control to Input Y

BUG FIXES
---------
• Fixed Autosort Bag legacy text export/import
• Fixed Upgraded PP to refill a move only when its maximum PP is first upgraded
• Fixed Interface settings to persist globally across saves and game restarts while keeping Battle Menu layout customization per-save
• Fixed File A Bug Report to open the dedicated Kanto Reloaded bug-report Discord thread
• Fixed Back input activating the highlighted row in shared popups

VISUALS & UI
------------
• Expanded About with Author and Discord Link rows
• Removed hint footers from category-only and action-only Options pages
• Aligned read-only option values with the value column used by adjustable options
• Rounded the type icons shown in TM Vault
• Updated standard shared confirmations to begin on Yes while serious prompts continue to begin on No

TECHNICAL
---------
• Added one-time migration for legacy Dynamic Randomizer wild and item settings

DEVELOPER
---------
• Added the stable `KantoReloaded::Randomizer` API contract and documented its guarded integration boundaries
• Added the stable `KantoReloaded::PCOrganization` menu-command registry contract
• Added Pokemon, box, and multi-selection action registries for extending Reloaded PC without replacing its menus
