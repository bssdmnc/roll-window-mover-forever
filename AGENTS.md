# Roll Window Mover Forever

WoW addon (single Lua file) that re-anchors the Blizzard loot roll window (`GroupLootContainer`, fallback `GroupLootFrame1`) to a draggable mover frame.

- Target client: WoW Forever, `C:\Program Files (x86)\World of Warcraft\_forever_` (also `_classic_beta_`), Interface 16001.
- Mechanism: `hooksecurefunc(frame, "SetPoint")` re-anchors the frame's BOTTOM to the mover whenever Blizzard repositions it; the last Blizzard anchor is remembered for `/rollmove reset`.
- SavedVariables `RollWindowMoverForeverDB` (account-wide): point, relativePoint, x, y, scale.
- Lua errors land in `<WoW>/_classic_beta_/Logs/General.log`.
- Code style: no inline comments.
- Release: bump `## Version` in the .toc, run `packaging/build.ps1`, upload `dist/*.zip` to CurseForge, tag `v<version>` on GitHub.
- CurseForge page text lives in `curseforge/description.md`.
