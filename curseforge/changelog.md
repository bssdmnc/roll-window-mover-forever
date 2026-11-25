## 1.3.0

- **Chat Roll Anti-Spam**: Group intermediate Need / Greed / Disenchant / Transmog / Pass chat lines into one compact expandable line (`[+ Rolls (N)]`). Clicking it expands/collapses all player rolls inline; works with both Blizzard Chat and **Chattynator**.
- **Roll History & Details Window (`/rollmove history`)**: Click `[Details]` / `[Rolls]` in chat (or `Shift + Right-click` the minimap button) to inspect who rolled what, class colors, `1–100` roll values, and the winner for the last 60 rolls. Hovering chat roll links shows an instant tooltip preview.
- **Loot History Sync**: Enriches participant rolls from `C_LootHistory` when available (helpful when Detailed Loot Information is disabled).
- **Test Mode Roll Simulation**: Clicking Need / Greed / Disenchant / Pass in `/rollmove test` now simulates a 5-player party roll and outputs the expandable summary to chat.
- **Russian (`ruRU`) Localization**: Translated settings window, anchor hints, minimap tooltips, chat buttons, and Roll History window.
- **Bug Fixes**:
  - Fixed test roll button hooks hiding real loot roll frames after `/rollmove test` was used earlier in the session.
  - Fixed "Hide in combat" so new loot roll windows opening mid-combat stay hidden until combat ends.

## 1.2.2

- Fixed loot roll window scaling inside `GroupLootContainer` and added support for 5–10 simultaneous visible rolls.

## 1.2.1

- Disabled "Hide in combat" by default.

## 1.2.0

- Added graphical settings window (`/rollmove config`), minimap button, combat hide toggle, and visible roll queue limit.

## 1.1.0

- Added 4-slot stack mover preview, `/rollmove test`, and interactive test roll mode.

## 1.0.0

- Initial release.
