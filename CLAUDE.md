# Ghostwood Approach — Claude Code Instructions

See [README.md](README.md) for game design, seasonal shifts, scoring, carriers, project structure, Lua conventions, and tooling commands.

## Context

I am new to Lua and new to game development. Write clean, well-commented code and explain key decisions as you go.

## Current milestone

Begin with **milestone 1**: a runnable Playdate project scaffold with a title screen that reads "GHOSTWOOD MUNICIPAL" and transitions to an empty shift screen on button press. Make sure it compiles and runs in the simulator before adding any game logic.

## Technical notes

- Target: **Playdate hardware** (also test in simulator)
- SDK: Playdate SDK (Lua API), already installed
- Use `playdate.graphics` aliased as `gfx` for drawing
- Use `playdate.update()` as the main game loop (60fps)
- Use `playdate.datastore` for persistent logbook storage
- No external libraries — standard SDK only
- Tables as objects pattern: `function Aircraft.new(...)`
- Time-based fuel tick using `playdate.getCurrentTimeMilliseconds()` or a frame counter
