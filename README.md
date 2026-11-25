# Roll Window Mover Forever

A lightweight World of Warcraft addon that lets you move and resize up to 10 Need / Greed / Pass loot roll windows, group roll chat spam into a single expandable line, and inspect who rolled what in a Roll History ledger.
Made for **WoW Forever** (`_forever_` / `_classic_beta_`, Interface 16001), also flagged for Classic Era (`11509`).

## Features

- **Move & Resize**: Drag the stack anchor anywhere and scroll to scale (`50%–200%`), with interactive preview for 1–10 rolls.
- **Roll Queue**: Configure `1–10` simultaneous visible loot roll frames; extra items wait in queue.
- **Chat Roll Anti-Spam**: Suppresses noisy intermediate roll lines and groups them into one clickable `[+ Rolls (N)]` line that expands inline (compatible with both Blizzard chat and **Chattynator**).
- **Roll History Ledger**: Click `[Details]` / `[Rolls]` in chat (or use `/rollmove history`) to inspect every player's choice, roll number, class color, and winner. Hover links in chat for a quick tooltip preview.
- **Hide in Combat & Minimap Button**: Optional combat hiding and quick-access minimap button (`enUS` / `ruRU`).

## Usage

| Command | What it does |
| --- | --- |
| `/rollmove` | Show or hide the loot roll anchor |
| `/rollmove config` | Open the graphical settings window |
| `/rollmove history` | Open the Roll History & details ledger |
| `/rollmove chatgroup` | Toggle grouping roll spam into one expandable chat line |
| `/rollmove chatbtn` | Toggle clickable `[Details]` / `[Rolls]` button on roll messages in chat |
| `/rollmove scale <0.5-2>` | Set the roll window scale |
| `/rollmove max <1-10>` | Set max simultaneous visible items (extra queue up) |
| `/rollmove combat` | Toggle hide roll windows while in combat |
| `/rollmove minimap` | Toggle minimap button |
| `/rollmove test [1-10]` | Show test loot roll windows and simulate chat roll grouping |
| `/rollmove reset` | Restore default position and settings |

While the box is shown: drag it with the left mouse button, scroll to resize, right-click to lock.
On the minimap button: left-click to unlock/lock, right-click for settings, `Shift + Left-click` for test rolls, `Shift + Right-click` for Roll History.

## Install

Copy `addon/RollWindowMoverForever` into `World of Warcraft/_forever_/Interface/AddOns/` (or `_classic_beta_/Interface/AddOns/`),
or install it from CurseForge.

## Build

```powershell
powershell -File packaging/build.ps1
```

Produces `dist/RollWindowMoverForever-<version>.zip` for CurseForge.

## License

GPL-3.0
