# Stillwater Approach — Claude Code Instructions

See [README.md](README.md) for game design, seasonal shifts, scoring, carriers, project structure, Lua conventions, and tooling commands.

## Context

I am new to Lua and new to game development. Write clean, well-commented code and explain key decisions as you go.

## Current milestone

Begin with **milestone 2**: a single aircraft card appears on the shift screen with callsign, fuel, and situation. Fuel ticks down visibly each second. No queue management yet — just one card on screen with a live countdown.

## Pull request instructions

When creating a PR for a completed milestone:
1. Check off the corresponding milestone checkbox in `README.md` (change `- [ ]` to `- [x]`)
2. Include the milestone name in the PR title (e.g. "Milestone 2: one aircraft card")

## Playdate references

- **SDK docs:** Validate API usage against https://sdk.play.date/3.0.3/Inside%20Playdate.html
- **Design guide:** Consider Playdate design best practices at https://help.play.date/developer/designing-for-playdate/

## Usage tracking

Session usage is logged to `.claude/usage-log.jsonl.local` (gitignored) via a Stop hook. The pre-commit hook automatically copies it over `.claude/usage-log.jsonl` before staging, so it's included in commits without extra steps.

No manual workflow needed — just commit normally.

## Running the simulator

To build and launch the simulator:

```
make sim
```

See all available make targets with `make help`.

## Technical notes

- Target: **Playdate hardware** (also test in simulator)
- SDK: Playdate SDK (Lua API), already installed
- Use `playdate.graphics` aliased as `gfx` for drawing
- Use `playdate.update()` as the main game loop (60fps)
- Use `playdate.datastore` for persistent logbook storage
- No external libraries — standard SDK only
- Tables as objects pattern: `function Aircraft.new(...)`
- Time-based fuel tick using `playdate.getCurrentTimeMilliseconds()` or a frame counter
