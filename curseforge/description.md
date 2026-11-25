# Roll Window Mover Forever

Move and resize the **Need / Greed / Pass** loot roll window, collapse noisy roll spam in chat into a single expandable line, and inspect who rolled what and who won. Made for **WoW Forever** (`Interface 16001`, also flagged for Classic Era `11509`).

## Features

- **Move & Scale Loot Rolls**: Drag the anchor anywhere on screen and scroll to scale (`50%–200%`). Preview the full stack height so loot never overlaps action bars or goes off-screen.
- **1–10 Visible Rolls + Queue**: Show anywhere from 1 to 10 simultaneous loot roll windows; extra drops wait neatly in queue and appear as you finish rolling.
- **Chat Roll Anti-Spam**: Suppresses intermediate `selected` and `Roll - X` chat spam and combines each item's roll into **one compact, expandable line**. Click **[+ Rolls (N)]** in chat to expand or collapse all player rolls inline.
- **Clickable Roll Details & History Ledger**: Click **[Details]** (or **[Rolls]**) next to the item in chat — or hover over it for an instant tooltip — to open the **Roll History** window showing every participant, class color, choice (Need / Greed / Disenchant / Transmog / Pass), `1–100` roll value, and winner. Keeps the last 60 rolls across reloads.
- **Hide in Combat**: Optional toggle to hide loot roll frames during combat and restore them when combat ends (including rolls that start mid-combat).
- **Compatible & Lightweight**: Zero external libraries, single Lua file, taint-safe, works with both **Blizzard Chat** and **Chattynator**, supports `C_LootHistory`, and localized in **English (`enUS`)** and **Russian (`ruRU`)**.

## How to use

1. Type **/rollmove** (or left-click the minimap button). A stack preview appears showing where the roll window sits and how items grow upwards.
2. **Drag** any box to place the stack where you want.
3. **Scroll** over any box to make the windows bigger or smaller.
4. **Right-click** any box (or type **/rollmove**) to lock and save.
5. Type **/rollmove test 4** anytime to preview stacked frames, test rolling, and try the collapsible chat summary without waiting for a dungeon drop.

## Commands

- **/rollmove**: show or hide the drag anchor
- **/rollmove config**: open the graphical settings window
- **/rollmove history**: open the Roll History & details ledger
- **/rollmove chatgroup**: toggle grouping roll spam into one expandable chat line
- **/rollmove chatbtn**: toggle the clickable **[Details]** / **[Rolls]** button in chat
- **/rollmove test [1-10]**: preview interactive test roll windows and chat roll grouping
- **/rollmove scale <0.5-2>**: set the roll window scale
- **/rollmove max <1-10>**: set max simultaneous visible rolls
- **/rollmove combat**: toggle hiding roll windows while in combat
- **/rollmove minimap**: toggle the minimap button
- **/rollmove reset**: restore default Blizzard position and settings

## Minimap Button

- **Left-click**: unlock or lock the anchor
- **Right-click**: open settings window
- **Shift + Left-click**: toggle test roll windows
- **Shift + Right-click**: open Roll History window
- **Drag**: position anywhere around the minimap

## Details

- Position, settings, and the last 60 roll entries are saved account-wide.
- Anchor and scale are reapplied automatically whenever a new roll appears, including in combat.
- Uses `/rollmove` so it doesn't conflict with other loot roll addons.

Source code: https://github.com/bssdmnc/roll-window-mover-forever
