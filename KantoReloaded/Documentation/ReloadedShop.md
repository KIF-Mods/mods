# Reloaded Shop

Kanto Reloaded replaces KIF's Kuray Shop purchase screen with the offline
`RLD Shop`. Ordinary NPC Marts keep their native screens and transaction
behavior; KR only extends their successful bulk-purchase rewards.

## Stock ownership

KIF remains responsible for building the available Kuray Shop stock and prices.
This preserves badge requirements, Streamer's Dream behavior, Rocket Ball
availability, K-Egg progression, and other base-game conditions.

Kanto Reloaded stores a per-save customization overlay for:

- category names and order
- item categories and custom order
- added, removed, and disabled items
- buy and sell price overrides
- favorite items

Resetting RLD Shop clears only this overlay.

## Controls

- Up/Down: select an item
- Left/Right: change category
- Confirm: buy or open editor actions
- Back: close
- Action: toggle favorite
- Special: open the RLD Mart controls popup
- L: cycle sorting
- R: toggle Quick Buy

Purchasing uses the same centered Reloaded Mart quantity and confirmation
panels as Hoenn Reloaded. The shared Mart picker also exposes the matching
green sale-total presentation for any future Reloaded Mart sell flow; the KIF
Kuray Shop integration itself remains buy-only.

Bulk purchases in both RLD Shop and ordinary NPC Marts award one bonus item
for every complete group of ten in the current transaction:

- every 10 Poke Balls award 1 Premier Ball
- every 10 DNA Splicers award 1 DNA Reverser
- every 10 Super Potions, Hyper Potions, or Max Potions award 1 Potion

Eligible Reloaded Shop quantity and confirmation panels preview the reward for
the selected quantity. Ordinary NPC Marts add the same preview to their native
purchase confirmation. A KR purchase-reward popup then reports the number of
bonus items added. If the Bag cannot hold the full reward, the popup reports
the partial or failed award.

Open the catalog editor from **Quality of Life > Reloaded Shop**. The editor
uses Left/Right to change panels and Action to add a category or item.

## Import and export

Catalog data is exported to:

`Mods/KantoReloaded/Exports/ReloadedShopCatalog.json`

The feature is entirely local. It has no online catalog, publishing,
automation, services, promo codes, alternate currencies, timed stock, bundles,
or reward system.

## Compatibility

Runtime integration uses guarded KR hooks:

- `PokemonPauseMenu_Scene#pbShowCommands` changes only the `Kuray Shop` label to
  `RLD Shop`.
- `PokemonMartScreen#pbBuyScreen` redirects only while KIF marks
  `$game_temp.fromkurayshop`.
- Standard Mart hooks track the selected item and quantity, then award bonuses
  only after `PokemonMartAdapter#setMoney` confirms a successful purchase.
- KIF's original single Premier Ball bonus is suppressed only after KR has
  awarded the complete per-10 reward.

Every wrapped Mart method delegates to its original implementation. KR does
not replace the native buy loop, quantity picker, item storage, or payment
logic.
