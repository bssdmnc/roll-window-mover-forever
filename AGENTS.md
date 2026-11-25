# Roll Window Mover Forever

WoW addon (single Lua file) that re-anchors the Blizzard loot roll window (`GroupLootContainer`, fallback `GroupLootFrame1..10`) to a draggable mover frame, groups loot roll chat spam into a collapsible summary line, and tracks roll history.

- Target client: WoW Forever, `C:\Program Files (x86)\World of Warcraft\_forever_` (also `_classic_beta_`), Interface 16001 (also flagged for Classic Era 11509).
- Mechanism: `hooksecurefunc(frame, "SetPoint")` re-anchors the frame's BOTTOM to the mover whenever Blizzard repositions it; the last Blizzard anchor is remembered for `/rollmove reset`. Chat grouping hooks `CHAT_MSG_LOOT` via `ChatFrame_AddMessageEventFilter`, `|Haddon:rwmf:*|h` hyperlinks via `EventRegistry` / `SetItemRef`, and `Chattynator.API.AddModifier` when Chattynator is loaded.
- SavedVariables `RollWindowMoverForeverDB` (account-wide): `point`, `relativePoint`, `x`, `y`, `scale`, `maxItems`, `hideInCombat`, `showMinimapButton`, `minimapPos`, `groupRollChat`, `chatRollButton`, `history`, `nextHistoryId`.
- Lua errors land in `<WoW>/_forever_/Logs/General.log` (and `_classic_beta_/Logs/General.log`).
- Code style: no inline comments.
- Release: bump `## Version` in the .toc, run `packaging/build.ps1`, upload `dist/*.zip` to CurseForge, tag `v<version>` on GitHub.
- CurseForge page text, summary, and changelog live in `curseforge/description.md`, `curseforge/summary.txt`, and `curseforge/changelog.md`.
