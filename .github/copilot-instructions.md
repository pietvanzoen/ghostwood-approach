---
excludeAgent: "coding-agent"
---

Stillwater Approach is a card-based ATC game for the [Playdate](https://play.date) — a handheld with a 400×240 1-bit display. Written in Lua using the Playdate SDK.

## Review focus

Flag these:
- Logic bugs: off-by-ones, wrong comparisons, incorrect state mutations
- Missing `nil` guards at module boundaries or when indexing optional fields
- Anything likely to cause frame drops at 60 fps (allocations in the update loop, redundant draws)
- Game balance issues visible from the code (e.g. fuel loads that make a shift unwinnable)

Do not flag these (already enforced by tooling or intentional):
- Line length — enforced at 120 columns by `make lint` (luacheck + stylua.toml)
- Missing comments on self-evident code — comments are intentionally minimal
- Missing type annotations — this project does not use LuaLS `@param`/`@return` blocks
- Abstractions that could be DRYed up but work correctly
- Drawing code in `source/cover.lua` — intentionally uncommented

## Game domain

- Altitude is **AGL** (feet above the runway). 0 = touchdown. Never suggest MSL.
- Fuel is in **seconds**. `fuel_max` = starting fuel, kept for scoring.
- **Lose condition is checked before win condition each tick** — intentional. A fuel-out on the final landing frame must resolve as a loss.
- The landing queue descends at `Constants.APPROACH_RATE` ft/sec. Holding aircraft maintain assigned altitude.
