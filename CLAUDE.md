# Stillwater Approach — Claude Code Instructions

See [README.md](README.md) for game design, seasonal shifts, scoring, carriers, project structure, Lua conventions, and tooling commands.

## Context

I am new to Lua and new to game development. Write clean, well-commented code and explain key decisions as you go.

## Current milestone

**Milestone 6: Win/lose + score screen** — shift ends, score calculated. See `README.md` for the full milestone list.

## Pull request instructions

When completing a milestone, before creating a PR:

1. **Update `README.md`** — check off the milestone checkbox (`- [ ]` → `- [x]`), and update any game mechanic descriptions affected by the work (e.g. altitude behaviour, controls, scoring). Keep README the source of truth for how the game actually works.
2. **Update `CLAUDE.md`** — advance the current milestone, and capture any new design decisions, conventions, or testing gotchas discovered during the session that future sessions should know about.
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

## Game design decisions

- **Altitude is AGL** (Above Ground Level, feet above the runway). 0 = touchdown. Never use MSL in game code or UI. See [`docs/atc-altitude-reference.md`](docs/atc-altitude-reference.md) for the ATC research behind this.
- **Holding aircraft**: altitude is static. **Landing queue aircraft**: altitude descends at `Constants.APPROACH_RATE` ft/sec. `Queue.land_front` is called when `landing[1].altitude <= 0`.

## Testing notes

- `Constants`, `Strings`, etc. are Playdate-style globals loaded via `import` — they are **not** available in the busted test environment automatically. Spec files that test modules depending on these globals must `require("source.constants")` (etc.) explicitly at the top, or tests will error with "attempt to index global 'Constants' (a nil value)".
