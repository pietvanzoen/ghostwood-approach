# Ghostwood Approach — Claude Code Instructions

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

After a fresh clone, mark the file with `skip-worktree` so it stays clean in `git status` and doesn't block branch switches:

```
git update-index --skip-worktree .claude/usage-log.jsonl
```

When committing, temporarily lift the flag to include the latest data:

```
git update-index --no-skip-worktree .claude/usage-log.jsonl
git add .claude/usage-log.jsonl
git update-index --skip-worktree .claude/usage-log.jsonl
```

The file is auto-updated after each response via a Stop hook.

## Running the simulator with logs

To build and launch the simulator with stdout log capture (enables reading `print()` output):

```
pdc source/ builds/ghostwood-approach.pdx && "$PLAYDATE_SDK_PATH/bin/Playdate Simulator.app/Contents/MacOS/Playdate Simulator" builds/ghostwood-approach.pdx
```

Run this as a background task and read the output file to access simulator logs.

## Technical notes

- Target: **Playdate hardware** (also test in simulator)
- SDK: Playdate SDK (Lua API), already installed
- Use `playdate.graphics` aliased as `gfx` for drawing
- Use `playdate.update()` as the main game loop (60fps)
- Use `playdate.datastore` for persistent logbook storage
- No external libraries — standard SDK only
- Tables as objects pattern: `function Aircraft.new(...)`
- Time-based fuel tick using `playdate.getCurrentTimeMilliseconds()` or a frame counter
