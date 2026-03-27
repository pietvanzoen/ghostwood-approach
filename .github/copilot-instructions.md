# Copilot Instructions — Stillwater Approach

Stillwater Approach is a card-based ATC game for the Playdate (a handheld with a 400×240 black-and-white display). It is written in Lua using the Playdate SDK.

## Code style

- Comments only where code cannot speak for itself: non-obvious *why* decisions, behavioral gotchas, magic-number semantics, subtle ordering constraints. Do not flag missing comments on self-evident code.
- No LuaLS `@param`/`@return` type annotations — do not suggest adding them.
- No external libraries. Standard Playdate SDK only.

## Lua conventions

- Only `nil` and `false` are falsy. `0`, `""`, and `{}` are truthy. Guard conditions should use `== nil` or `~= nil` explicitly when checking for the absence of a value — do not suggest replacing these with `not x` when `x` could be `0`.
- Module pattern: `function Module.new(...)` returning a plain table. No metatables or OOP inheritance.
- State is mutated in place (queue state, cursor) rather than returned as new values — this is intentional.

## Game domain

- Altitude is AGL (Above Ground Level, feet above the runway). 0 = touchdown. Do not suggest MSL conversions.
- Fuel is in seconds. `fuel_max` stores the starting fuel for efficiency scoring.
- The landing queue descends at `Constants.APPROACH_RATE` ft/sec. Holding aircraft maintain their assigned altitude.
- Lose condition is checked before win condition each tick — this is intentional (fuel-out on the final frame resolves as a loss).

## What to focus reviews on

- Logic correctness: off-by-ones, wrong comparisons, state mutation bugs
- Playdate constraints: anything that would cause performance issues at 60 fps on limited hardware
- Game balance issues visible from the code (e.g. fuel margins that make a shift unwinnable)
- Missing nil guards at boundaries

## What to skip

- Style suggestions that conflict with the conventions above
- Suggestions to add type annotations or docstrings to every function
- Refactors that increase abstraction without fixing a real problem
- Comments on drawing code in `cover.lua` — it is intentionally uncommented
