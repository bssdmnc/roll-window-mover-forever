# Roll Window Mover Forever

Move and resize the **Need / Greed / Pass** loot roll window. Made for **WoW Forever**.

## How to use

1. Type **/rollmove**. A 4-slot stack preview appears showing where the roll window sits and how items grow upwards.
2. **Drag** any box to place the stack where you want.
3. **Scroll** over any box to make the windows bigger or smaller.
4. **Right-click** any box (or type /rollmove again) to lock it.

## Commands

- **/rollmove**: show or hide the drag box
- **/rollmove test [1-5]**: preview 1 to 5 test roll windows (type again to hide)
- **/rollmove scale 0.5-2**: set the scale
- **/rollmove reset**: back to the default Blizzard position

## Details

- Shows full 4-item stack height so loot never overlaps UI or goes off-screen.
- The position is saved for all characters on your account.
- It is reapplied every time a new roll appears, also in combat.
- Lightweight: no libraries, no options window, a single Lua file.
- Uses /rollmove so it doesn't conflict with other loot roll addons.

Source code: https://github.com/bssdmnc/roll-window-mover-forever
