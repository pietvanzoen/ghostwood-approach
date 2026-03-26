# Stillwater Approach — Agent Instructions

See [README.md](README.md) for game design, seasonal shifts, scoring, carriers, project structure, Lua conventions, and tooling commands.

## Context

I am new to Lua and new to game development. Write clean, well-commented code and explain key decisions as you go.

## Current milestone

**Milestone 8: Emergency cards** — medevac and SAR with time-based pressure. See `README.md` for the full milestone list.

## Pull request instructions

When completing a milestone, before creating a PR:

1. **Update `README.md`** — check off the milestone checkbox (`- [ ]` → `- [x]`), and update any game mechanic descriptions affected by the work (e.g. altitude behaviour, controls, scoring). Keep README the source of truth for how the game actually works.
2. **Update `AGENTS.md`** — advance the current milestone, and capture any new design decisions, conventions, or testing gotchas discovered during the session that future sessions should know about.
3. **Create the PR** — include the milestone name in the PR title (e.g. "Milestone 2: one aircraft card").

## Repository

**GitHub:** https://github.com/pietvanzoen/stillwater-approach

Use the GitHub REST API to access PRs and comments when `gh` is unavailable:
```
https://api.github.com/repos/pietvanzoen/stillwater-approach/pulls?state=open
https://api.github.com/repos/pietvanzoen/stillwater-approach/pulls/<n>/comments
```

## Playdate references

- **SDK docs:** Validate API usage against https://sdk.play.date/3.0.3/Inside%20Playdate.html
- **Design guide:** Consider Playdate design best practices at https://help.play.date/developer/designing-for-playdate/

## Usage tracking

Session usage is logged to `.claude/usage-log.jsonl.local` (gitignored) via a Stop hook. The pre-commit hook (`_scripts/pre-commit.sh`) merges it into the tracked `.claude/usage-log.jsonl` before each commit automatically.

`make install` installs the hook. No other manual steps needed — just commit normally.

## Dev setup

```
make install  # install dependencies and git hooks
make help     # see all available targets
```

Run the simulator with `make sim`. Requires the Playdate SDK installed locally.

## Release workflow

Only release when changes affect the installed game (features, fixes, UI, mechanics). Do not release for tooling, docs, or build-system-only changes.

To release a new version:

```
make release VERSION=x.y.z
```

This updates `source/pdxinfo`, commits with message `Release vX.Y.Z`, and tags the commit. Review the changes, then push with the command it echoes. The GitHub release workflow is triggered automatically on tag push.

## Technical notes

- Target: **Playdate hardware** (also test in simulator)
- SDK: Playdate SDK (Lua API) — install from play.date/dev/ for local builds
- Use `playdate.graphics` aliased as `gfx` for drawing
- Use `playdate.update()` as the main game loop (60fps)
- Use `playdate.datastore` for persistent logbook storage
- No external libraries — standard SDK only
- Tables as objects pattern: `function Aircraft.new(...)`
- Time-based fuel tick using `playdate.getCurrentTimeMilliseconds()` or a frame counter

## Reference docs

A `docs/` folder holds research and reference material that informed game design decisions. When a session involves non-trivial external research — ATC protocols, aviation conventions, hardware behaviour, real-world data — consider saving the findings to a file in `docs/` rather than discarding them. Good candidates:

- Real-world research that shaped a mechanic (e.g. holding altitudes, approach procedures)
- External rules or standards the game approximates (FAA regs, scoring conventions)
- Design rationale that isn't obvious from the code alone

Keep filenames specific (e.g. `atc-altitude-reference.md`, not `notes.md`). Existing docs: [`docs/atc-altitude-reference.md`](docs/atc-altitude-reference.md).

## ATC realism and playability

The game aims for **felt authenticity** — real ATC conventions should inform mechanics, but always adapted for fun and accessibility. Players shouldn't need to understand actual ATC to enjoy the game.

When implementing mechanics that touch real-world aviation (altitudes, holding patterns, approach procedures, emergencies, callsigns):
1. **Research the real convention first** — use WebSearch and WebFetch to find FAA/ICAO sources. Save meaningful findings to `docs/` (see Reference docs section).
2. **Then adapt for gameplay** — simplify timescales, abstract away complexity that doesn't add fun, but let the real-world logic shape the design.
3. **When realism and fun conflict, fun wins** — but document the trade-off so the reasoning is preserved.

See [`docs/atc-altitude-reference.md`](docs/atc-altitude-reference.md) for an example of this approach applied to holding altitudes and approach procedures. See the README "ATC realism vs. playability" section for the player-facing statement of this principle.

## Season and schedule architecture

- **`seasons.lua`**: Each season is a function (`Seasons.spring()`, etc.) returning a sorted `schedule` array of `{ time, aircraft }` entries. `main.lua` assigns the result to `shift_state.schedule`. New seasons are added by adding a new function — no other files need to change.
- **`aircraft.notes`**: Optional 5th param to `Aircraft.new()`. Holds short flavor text (radio chatter, weird escalation hints). Shown at the bottom of the shift screen (`Constants.NOTES_BAR_Y`) when that aircraft is the cursor focus. `nil` notes show nothing (no bar).
- **Notes bar**: Drawn in `UI.draw_shift_screen` via `focused_aircraft()` helper. A thin divider line at `NOTES_BAR_Y - 4`, notes text at `NOTES_BAR_Y`. Only drawn when the focused aircraft has `notes ~= nil`. This keeps the card list uncluttered while still surfacing flavor text.
- **Spring schedule design**: 6 aircraft, arrivals every 25–35 s, generous fuel loads (30–70 s margins if promoted immediately). Altitudes 2500–4000 ft. Two Medical situations (GCS1 SAR, CAM1 medevac) provide moderate time pressure. PTA7 carries the weird escalation note.
- **`flavor.lua`** (planned, Milestone 11): When there are multiple seasons with complex escalation, extract flavor text into a dedicated module. For now, notes live inline in `seasons.lua`.
- **Weird escalation pattern:** Aircraft notes field holds flavor text (radio chatter, cryptic hints). Surface via notes bar at bottom of shift screen when focused. Example: PTA7 mentions the Packard road in Spring.

## Game design decisions

- **Altitude is AGL** (Above Ground Level, feet above the runway). 0 = touchdown. Never use MSL in game code or UI. See [`docs/atc-altitude-reference.md`](docs/atc-altitude-reference.md) for the ATC research behind this.
- **Holding aircraft**: altitude is static. **Landing queue aircraft**: altitude descends at `Constants.APPROACH_RATE` ft/sec. `Queue.land_front` is called when `landing[1].altitude <= 0`.
- **Display rounding**: Round display values (e.g., altitude to tens) independently from internal state for visual clarity without affecting game logic.
- **Landing queue separation**: Enforce MIN_LANDING_SEP per-tick in `Queue.tick_all` by checking previous aircraft altitude; prevents confusion from multiple aircraft descending at nearly the same altitude.
- **Dwell state**: Use aircraft property (e.g., `touchdown_timer`) for transient UI states (e.g., showing "Landed"); keeps state colocated with data.
- **Scoring formula**: base(50) + efficiency(0–50, avg fuel % remaining) − near_miss_penalty(10 each). Score clamped to 0. Failed shifts always score 0 regardless of efficiency. A "near miss" = fuel < 10% of `fuel_max` at touchdown (`Constants.CRITICAL_FUEL_PCT`). `fuel_max` is stored on Aircraft.new for display and scoring.
- **Win/lose state machine**: Lose check runs before win check each tick so a fuel-out on the final landing frame resolves as a loss, not a win. Score screen (`STATE_SCORE`) transitions back to `STATE_TITLE` on A button; all shift/score state is cleared.
- **Dwell state and fuel-out**: `Queue.find_out_of_fuel` skips aircraft with `touchdown_timer` set — they are safely on the ground and must not trigger a failure even if fuel reads 0.
- **Debug shortcuts**: Use `if DEBUG and playdate.buttonJustPressed(playdate.kButtonB) then` pattern for quick in-shift testing shortcuts. Remove before merging.
- **Failed shift score_result**: `avg_fuel_pct` is set to 0 on the lose path (not carried from partial stats) so the score screen never shows a misleading efficiency % alongside total = 0.

## Playdate font limitations

- **Roobert-9-Mono-Condensed** (bitmap font) supports ASCII only; UTF-8 glyphs (▼, ⚠️, etc.) render as unknown diamonds. Use ASCII alternatives (v, !, etc.) for UI symbols. Update both code and comments to reflect the actual symbol being used.

## Testing notes

- `Constants`, `Strings`, etc. are Playdate-style globals loaded via `import` — they are **not** available in the busted test environment automatically. Spec files that test modules depending on these globals must `require("source.constants")` (etc.) explicitly at the top, or tests will error with "attempt to index global 'Constants' (a nil value)".
- Test assertions: use `assert.equal(...)` consistently across all specs (not `assert.equals`). This keeps assertions uniform for grepping and readability.
- On macOS, luacheck and busted are installed as Homebrew formulae (not luarocks) to avoid lua version conflicts. If `make lint`/`make test` fail after a Homebrew update, run `make install` again (it uses `--force` to reinstall).
- **Lua truthiness**: Only `nil` and `false` are falsy. `0`, `""`, and `{}` are all truthy. This differs from C/JS/Python — guard conditions like `== nil` and `not x` behave differently when `x` is `0`.
