# Ghostwood Approach — Claude Code Instructions

See [README.md](README.md) for game design, seasonal shifts, scoring, carriers, project structure, Lua conventions, and tooling commands.

## Context

I am new to Lua and new to game development. Write clean, well-commented code and explain key decisions as you go.

## Current milestone

Begin with **milestone 1**: a runnable Playdate project scaffold with a title screen that reads "GHOSTWOOD MUNICIPAL" and transitions to an empty shift screen on button press. Make sure it compiles and runs in the simulator before adding any game logic.

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

## Technical notes

- Target: **Playdate hardware** (also test in simulator)
- SDK: Playdate SDK (Lua API), already installed
- Use `playdate.graphics` aliased as `gfx` for drawing
- Use `playdate.update()` as the main game loop (60fps)
- Use `playdate.datastore` for persistent logbook storage
- No external libraries — standard SDK only
- Tables as objects pattern: `function Aircraft.new(...)`
- Time-based fuel tick using `playdate.getCurrentTimeMilliseconds()` or a frame counter
