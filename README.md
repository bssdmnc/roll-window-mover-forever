# Roll Window Mover Forever

A tiny World of Warcraft addon that lets you move and resize the Need / Greed / Pass loot roll window.
Made for WoW Forever (`_classic_beta_`, Interface 16001), also flagged for Classic Era.

## Usage

| Command | What it does |
| --- | --- |
| `/rollmove` | Show or hide the blue drag box |
| `/rollmove scale 0.5-2` | Set the roll window scale |
| `/rollmove test [1-5]` | Show 1 to 5 test loot roll windows (or hide them) |
| `/rollmove reset` | Restore the default Blizzard position and scale |

While the box is shown: drag it with the left mouse button, scroll to resize, right-click to lock.
The position is saved account-wide and reapplied every time a new roll appears.

## Install

Copy `addon/RollWindowMoverForever` into `World of Warcraft/_classic_beta_/Interface/AddOns/`,
or install it from CurseForge.

## Build

```powershell
powershell -File packaging/build.ps1
```

Produces `dist/RollWindowMoverForever-<version>.zip` for CurseForge.

## License

GPL-3.0
