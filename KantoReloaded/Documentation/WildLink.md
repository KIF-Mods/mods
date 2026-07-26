# Wild Link

Wild Link is Kanto Reloaded's targeted wild Pokemon search system. It is opened
from the Overworld Menu and does not replace or modify KIF's Poke Radar files.

## Availability

Wild Link reads the current map's native encounter tables and supports:

- Land
- Cave
- Surf
- Fishing
- Headbutt
- Rock Smash

Fishing requires an owned rod. Headbutt and Rock Smash are shown only when a
compatible nearby map event and encounter table both exist. Wild Link is
disabled in Safari, Bug Contest, partner, and non-map contexts.

Rock Smash requires the current map's dedicated `RockSmash` encounter table.
It never borrows species from Cave or Land tables.

## Discovery

- Unseen standard Pokemon appear as silhouettes and cannot be selected.
- Seen Pokemon can be searched.
- Caught Pokemon use colored icons and unlock full scan details.
- Search Level is permanent and stored per exact species or fusion.
- Search Level is capped at 999.
- Naturally encountered fusion identities are remembered per map and encounter
  method, then added to that method's searchable roster.
- Rare Signal uses KIF's native `Settings::POKE_RADAR_ENCOUNTERS` data.
- Rare Signal unlocks after every standard Land encounter on the map has been
  seen.
- An encountered Rare Signal species joins the normal searchable roster.

## Target Lifecycle

Land, Cave, and Surf searches create one temporary overworld target. Fishing,
Headbutt, and Rock Smash preserve their native field interactions and replace
only the final matching encounter.

Fishing marks its water tile with a centered ripple. Headbutt repeatedly
rustles the leaves of the affected native tree. Rock Smash traces the affected
native rock sprite with a pulsing white outline. These field methods do not
create Pokemon overworld sprites. Using Headbutt on the marked tree always
starts the prepared target instead of running KIF's normal tree encounter
chance. Smashing the marked rock always starts the prepared Wild Link
encounter and never runs KIF's normal item-reward roll.

While a target is active, ordinary step encounters are suppressed without
changing Repel. The target and chain are cleared by map changes, trainer
battles, target replacement, native Poke Radar activation, fleeing, losing, or
loading another save. Menus do not break a chain.

Wild Link passes the exact generated Pokemon object to KIF's native wild battle
core. The target's level, personality, IVs, ability, moves, held item, and shiny
state are therefore preserved.

## Overworld Reactions

Direct Land, Cave, and Surf targets transition between roaming and noticed
states. Each transition into the noticed state plays one of KIF's native
Hoenn-style reaction graphics:

- Curious targets show a question mark, approach, observe the player, and may
  hop or look around while nearby.
- Aggressive targets show anger and charge from farther away.
- Territorial targets show anger but approach only within their territory.
- Skittish and Elusive targets show an exclamation mark and retreat.
- Calm targets continue roaming and face the player without an alert.

When the player leaves detection range, non-fleeing targets return to roaming.
Skittish non-shiny targets that remain frightened for too long use a staged
Hoenn-style escape: they cry, play the flee sound, move away, fade out, and end
the chain. Shiny targets never flee or distance-despawn.

## Progression

- Knockout: Search Level +1 and Chain +1.
- Catch: Search Level +2 and Chain +1.
- Run, loss, or target escape: no Search Level gain and the chain ends.
- Chains are scoped to exact species/fusion, encounter method, and map.

`Continue Search` has three settings:

- `Prompt`: ask after a successful target.
- `Automatic`: begin the next target automatically.
- `Off`: preserve the chain but require Wild Link to be opened again.

Declining the `Prompt` ends the current chain.
Continuation waits for at least eight stable overworld updates after battle.

The Wild Link scene shows the current Search Level and chain bonus preview for
the selected Pokemon. The preview is calculated by the same helpers used to
generate the target and includes level, shiny-roll, perfect-IV, Hidden Ability,
Egg Move, and held-item bonuses. Unavailable species bonuses display `N/A`.

While a target or chain is active, `Action` in the Wild Link scene cancels the
target and ends its chain after confirmation. The `Cancel Link` footer command
can also be clicked with the mouse.

`Messages` controls routine Wild Link prompts, warnings, and notifications.
Turning it off automatically accepts normal search-flow confirmations. The
configured `Continue Search` prompt and the destructive Search Level reset
confirmation always remain available.

## Scan Unlocks

| Search Level | Detail |
| ---: | --- |
| 1 | Target level |
| 5 | Temperament |
| 10 | IV potential |
| 15 | Held item |
| 20 | Ability |
| 25 | Egg Moves |
| 50 | Exact signal direction and distance |

IV, item, ability, and Egg Move details require the species to be caught.
Shininess is never disclosed in the selection roster.
When Double Abilities is active, an eligible fusion's unlocked scan details
show Ability 1 and Ability 2 separately.

## Shiny Rolls

Additional shiny attempts are independent and apply only to Wild Link targets.
Native shiny generation, Shiny Charm behavior, and the current game shiny odds
run first.

Search Level rolls:

| Search Level | Extra Rolls |
| ---: | ---: |
| 0-24 | 0 |
| 25-99 | 1 |
| 100-199 | 2 |
| 200-499 | 3 |
| 500-999 | 4 |

Chain rolls:

| Chain | Extra Rolls |
| ---: | ---: |
| 0-9 | 0 |
| 10-19 | 1 |
| 20-49 | 2 |
| 50-149 | 3 |
| 150+ | 4 |

The combined Wild Link bonus is capped at eight additional rolls.

## Perfect IVs

Search Level:

- 25-49: 15% chance of one perfect IV.
- 50-99: one guaranteed perfect IV.
- 100-199: one guaranteed, with a 20% chance of a second.
- 200-499: two guaranteed perfect IVs.
- 500-999: two guaranteed, with a 20% chance of a third.

Chain:

- 30-49: 50% chance of one additional perfect IV.
- 50-99: at least two perfect IVs.
- 100-149: at least three perfect IVs.
- 150+: at least four perfect IVs.

Wild Link never guarantees more than four perfect IVs.

## Hidden Ability

Base Search Level chance:

| Search Level | Chance |
| ---: | ---: |
| 0-9 | 0% |
| 10-24 | 2% |
| 25-49 | 5% |
| 50-99 | 8% |
| 100-199 | 12% |
| 200-499 | 18% |
| 500-999 | 25% |

Chain adds 5%, 10%, 15%, 20%, or 25% at chains 10, 20, 50, 100, and 150.
The combined chance is capped at 50% and is skipped when no Hidden Ability
exists.

When Double Abilities is active for an eligible fusion, Wild Link can replace
Ability 1 only with a legal Hidden Ability from Ability 1's recorded component.
If that component has no legal Hidden Ability, the generated ability pair is
left unchanged.

## Egg Moves

A target can receive up to two distinct Egg Moves from its species data. The
first move begins unlocking at Search Level 10 or Chain 10. The second move
requires Search Level 100 or Chain 50 and is rolled only if the first succeeds.
The first and second chances are capped at 90% and 65%, respectively.

First Egg Move base chance:

| Search Level | Chance |
| ---: | ---: |
| 0-9 | 0% |
| 10-24 | 10% |
| 25-49 | 20% |
| 50-99 | 30% |
| 100-199 | 40% |
| 200-499 | 55% |
| 500-999 | 70% |

First Egg Move chain bonus:

| Chain | Added Chance |
| ---: | ---: |
| 0-9 | 0% |
| 10-19 | 5% |
| 20-49 | 10% |
| 50-99 | 15% |
| 100-149 | 20% |
| 150+ | 25% |

Second Egg Move base chance:

| Search Level | Chance |
| ---: | ---: |
| 0-99 | 0% |
| 100-199 | 10% |
| 200-499 | 20% |
| 500-999 | 30% |

Second Egg Move chain bonus:

| Chain | Added Chance |
| ---: | ---: |
| 0-49 | 0% |
| 50-99 | 15% |
| 100-149 | 25% |
| 150+ | 35% |

## Held Items

KIF's native wild held-item generation runs first. Wild Link then performs a
separate Search-Level and chain-based item roll using only that species' native
common, uncommon, and rare held-item table. A successful roll can assign a
native item when KIF generated none, or upgrade an existing result to a
higher-ranked native item. It never introduces generic items or downgrades a
native result. The combined bonus-roll chance is capped at 60%.

Base upgrade chance:

| Search Level | Chance |
| ---: | ---: |
| 0-9 | 0% |
| 10-24 | 5% |
| 25-49 | 10% |
| 50-99 | 15% |
| 100-199 | 20% |
| 200-499 | 25% |
| 500-999 | 30% |

Chain upgrade bonus:

| Chain | Added Chance |
| ---: | ---: |
| 0-9 | 0% |
| 10-19 | 5% |
| 20-49 | 10% |
| 50-99 | 15% |
| 100-149 | 20% |
| 150+ | 30% |

When an upgrade roll succeeds, Search Level and chain progression also shift
the selection weight from the species' common item toward its uncommon and
rare items. Rare-item weight is capped at 40%, uncommon-item weight at 55%,
and common-item weight never falls below 10%.

## Level Bonus

Only Search Level affects target level:

| Search Level | Added Levels |
| ---: | ---: |
| 0-9 | 0 |
| 10-24 | 0-1 |
| 25-49 | 0-2 |
| 50-99 | 1-2 |
| 100-199 | 1-3 |
| 200-499 | 2-4 |
| 500-999 | 3-5 |

The result is capped at KIF's normal maximum level.

## Integration Boundaries

- No KIF base files are edited.
- Native field-move prompts and animations remain authoritative.
- Native Poke Radar and Wild Link are mutually exclusive through guarded
  confirmation prompts.
- Wild Link owns and disposes only its temporary event and sprite.
- KIF's global randomizer mapping is applied once to each encounter-table
  species, so a source species has a stable randomized Wild Link identity.
- KIF's area randomizer is respected through the already-randomized encounter
  table loaded for the current map.
- KR Dynamic Pokemon intentionally does not reroll a selected Wild Link
  target. Dynamic rerolls wrap KIF's normal `choose_wild_pokemon` path, while
  Wild Link directly generates the species explicitly selected in its roster.
- Fusion targets retain the exact fusion for battle and use the body Pokemon's
  dark silhouette in the overworld.
