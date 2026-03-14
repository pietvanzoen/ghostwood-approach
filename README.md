# Stillwater Approach

A card-based air traffic control game for the [Playdate](https://play.date) handheld console, set at **Stillwater Municipal Airport** — a small remote airstrip in the Pacific Northwest with a Twin Peaks-inspired aesthetic (folksy but weird).

<img width="400" height="240" alt="playdate-20260309-212109" src="https://github.com/user-attachments/assets/e6b202ee-bbd0-437a-853b-21c5d650f4f3" />
<img width="400" height="240" alt="playdate-20260309-212132" src="https://github.com/user-attachments/assets/97d8b4a0-b452-456a-8eef-84bab030f808" />


---

## Setting

**Stillwater Municipal Airport — KSTW**

A single-runway airport nestled in a river valley between two forested ridgelines in the Cascades foothills of Washington State. Surrounded by old-growth timber (most of it logged — locals don't go into the part that wasn't). A river runs along the valley floor and floods every few years. Fog rolls in from the coast unpredictably. A mountain pass to the east gets socked in with clouds in winter.

Population of Stillwater: ~1,200. Timber industry. A diner. A lodge up in the hills. The airport has been here since the 1950s. Old equipment. Flickering fluorescents. A paper logbook.

You are the only one in the tower tonight.

---

## Game concept

Aircraft call in one by one requesting landing clearance. Each aircraft is represented as a **card** showing:

- **Callsign** (see carrier list below)
- **Fuel remaining** (a countdown — creates time pressure)
- **Altitude** *(planned)* — how close the aircraft is to landing; drives approach sequencing
- **Situation** (Normal / Low Fuel / Emergency / Priority / Unknown)
- **Aircraft type** (see aircraft list below)
- **Notes** (flavor text, sometimes a clue something is wrong)

The player manages two lists:
- **Landing queue** — ordered list of aircraft that will land in sequence
- **Holding stack** — aircraft waiting, burning fuel, decision deferred

Each tick, fuel decreases for all airborne aircraft. If any aircraft hits 0 fuel before landing, the shift ends in failure. Emergency and priority aircraft have time-based pressure independent of fuel. If all aircraft land safely, the player wins.

**Score** is based on how close aircraft came to running out of fuel and how cleanly emergencies were handled — efficient, calm sequencing scores higher than chaotic last-second saves.

The shift ends after all scheduled aircraft for that season have landed (or one crashes).

---

## Controls

- **D-pad up/down** — navigate cursor through landing list and holding list (cursor crosses section boundary automatically)
- **A button (on holding card)** — promote aircraft to bottom of landing list (max 3)
- **A button (on landing card)** — no-op; landing cards can't be selected or moved directly
- **B button** — cancel / back
- **Crank** — scroll through cards (secondary, nice to have)

---

## Carriers & callsigns

| Callsign | Type | Notes |
|---|---|---|
| Stillwater Air | Local commuter (Dash 8) | Runs to Seattle, Portland, Spokane. Workhorse of the airport. |
| Sill Valley Cargo | Freight prop | Timber industry supply runs |
| Pacific Timber Air | King Air charter | Company plane for the mill |
| Quillayute Charters | Small prop | Coastal hops. Fishy reputation. |
| Cascades Air Medical | Medevac fixed wing | Out of Yakima. Time is always the issue. |
| Cascades Medevac | Medevac helicopter | Organ transport. Requests immediate clearance. |
| Tanker 81 / Retardant 6 | Fire tanker | Returns from drops low on fuel, needs to reload and return |
| Spotter Kilo | Fire spotter | Small prop, needs to land and brief ground crew |
| Grays County SAR | Search & Rescue | Sheriff dept. Crew exhausted. Weather closing in. |
| Coast Guard 1471 | Coast Guard | Diverted inland. Won't say why. |
| [No callsign filed] | Unknown | ... |

---

## Aircraft types

| Type | Notes |
|---|---|
| Cessna 172 | Weekend pilots, charters, spotters |
| De Havilland Dash 8 | Stillwater Air's commuter workhorse |
| Beechcraft King Air | Corporate, timber company |
| Bell 206 helicopter | Medevac, SAR |
| Bombardier Q400 | Occasional larger commuter |
| Douglas DC-3 | Old cargo plane. Shouldn't still be flying. |
| [Unregistered] | No type on file. |

---

## Situation types

| Situation | Description |
|---|---|
| Normal | Standard approach request |
| Low Fuel | Fuel countdown accelerated |
| Emergency | Immediate priority, time critical |
| Cargo Shift | Unstable load, can't hold pattern long |
| Medical | Patient on board, time sensitive |
| Weather Divert | Diverted from another airport, low on options |
| Unknown | No flight plan filed. Pilot sounds strange. |

---

## Radio flavor text examples

- *"Stillwater Air 4, reporting smooth skies over the pass"*
- *"Visibility dropping. Fog coming in off the Sill."*
- *"Cargo shifted on approach. Declaring emergency."*
- *"Pilot says he's been flying this route 22 years and something looks different tonight."*
- *"Flight plan filed from Quillayute. No record of departure."*
- *"Smoke visible from the tower. Winds shifting."*
- *"Tanker 81 requesting clearance."* (You've already cleared Tanker 81 twice tonight.)

---

## The four seasonal shifts

Each shift is a self-contained run with its own conditions, traffic mix, emergencies, and weird escalation. Difficulty increases Spring -> Summer, with Fall and Winter being medium/medium-hard.

---

### SPRING — "The Thaw"
*April. The Sill River is running high. Mud season.*

- **Conditions:** Low cloud ceiling, intermittent rain, fog rolling up the valley. Visibility variable.
- **Traffic:** Light. Stillwater Air commuters, a few small props, season's first charters.
- **Emergencies:** Search & Rescue (missing hikers, snowmelt season), one medevac, a small plane caught in weather over the pass.
- **Weird escalation:** A pilot mentions the old Packard logging road is flooded. Says he saw something in the water from altitude. Doesn't elaborate.
- **Difficulty:** Tutorial-paced. Forgiving. Introduces core mechanics.
- **Scoring bonus:** Clean approaches (no go-arounds)

---

### SUMMER — "Fire Season"
*August. Dry. Hot. The ridge to the east has been burning for two weeks.*

- **Conditions:** Smoke haze reduces visibility. Thermals make approaches unpredictable. Winds shift without warning.
- **Traffic:** Heaviest of the year. Fire tankers cycling in and out constantly. Spotters. Crew transport. Normal commuters who don't care about the fire.
- **Emergencies:** Tanker declares emergency (retardant door jammed, can't land with full load). Medevac for a firefighter. A charter pilot who flew through smoke and is disoriented.
- **Weird escalation:** Tanker 81 checks in. You've cleared Tanker 81 three times tonight. There are only two tankers assigned to this fire.
- **Difficulty:** Hardest shift. Most planes, most emergencies, worst conditions.
- **Scoring bonus:** Tanker cycling speed (how fast you turn them around)

---

### FALL — "The Quiet"
*October. Timber season winding down. Days getting short.*

- **Conditions:** Clear and cold in the morning, fog by afternoon. Early darkness catches pilots off guard. First frost on the runway possible.
- **Traffic:** Medium. Timber company charters wrapping up. Hunting season brings small props. Stillwater Air cuts service to 3 days a week.
- **Emergencies:** Sheriff SAR (hunter didn't come back). Timber company King Air with a sick passenger. One night flight that shouldn't be there.
- **Weird escalation:** A DC-3 checks in. Tail number is in your logbook — from a shift three years ago. That flight never landed.
- **Difficulty:** Medium. Fewer planes but stranger ones. Fog timing creates pressure.
- **Scoring bonus:** Fog window management (landing aircraft in clear windows)

---

### WINTER — "The Long Dark"
*December. Pass is closed half the time. You're the only one here most days.*

- **Conditions:** Snow, ice, reduced runway length. Whiteout possible. Equipment running slow in the cold. The tower heater is unreliable.
- **Traffic:** Sparse but critical. Every flight that comes in is coming in because it has to. Holiday medevacs. A mail plane. The Coast Guard diversion that won't explain itself.
- **Emergencies:** Medevac in a snowstorm. A plane that declared emergency over the pass and then went silent. Coast Guard 1471, again.
- **Weird escalation:** On the last approach of the night, a voice checks in on a frequency that hasn't been active since 1987. Callsign: Stillwater Air 1.
- **Difficulty:** Medium-hard. Low volume but high stakes. Every decision matters more.
- **Scoring bonus:** Clean runway landings (no ice-related go-arounds)

---

## Scoring system

- **Base score:** All aircraft land safely = shift complete
- **Efficiency score:** Average fuel remaining across all aircraft on landing (higher = better)
- **Emergency score:** Emergency / medical aircraft landed within time window = bonus
- **Near miss penalty:** Any aircraft that hit critical fuel (< 10%) = score deduction
- **Seasonal bonus:** See per-season bonus above
- **Weird bonus:** Hidden. Triggered by specific weird escalation events. Player may not know what caused it.

Failure state: any aircraft hits 0 fuel, or an emergency aircraft exceeds its time window. Shift ends immediately. Score screen shows what went wrong.

---

## Tone & aesthetic

- Black and white Playdate graphics
- Lo-fi, unhurried. Small airport energy.
- Pilot radio chatter is folksy and slightly odd
- As the shift progresses, things get subtly weirder — unusual callsigns, strange situations, a flight number you've seen before
- No jump scares, no explicit horror — just a creeping sense that something is off
- The logbook persists across sessions — player can see every aircraft they've ever cleared

---

## Project structure

```
source/
  main.lua              -- entry point
  aircraft.lua          -- aircraft data, card logic, fuel countdown
  queue.lua             -- landing queue and holding stack management
  ui.lua                -- drawing cards, lists, status display
  game.lua              -- game state, shift logic, win/lose, scoring
  seasons.lua           -- season definitions, traffic generation, conditions
  flavor.lua            -- callsigns, radio text, weird escalation events
  logbook.lua           -- persistent logbook across sessions
```

---

## Build order (milestones)

- [x] **Scaffold** — blank Playdate project runs, shows title screen "STILLWATER APPROACH", starts a shift on button press
- [x] **One aircraft card** — a single aircraft appears with callsign, fuel, situation. Fuel ticks down visibly.
- [x] **Queue & holding** — player can move aircraft between landing queue and holding stack
- [x] **Multiple aircraft** — new aircraft arrive over time, player juggles several at once
- [ ] **Landing resolution** — aircraft at front of queue lands after a timer, shift progresses
- [ ] **Win/lose + score screen** — shift ends, score calculated
- [ ] **Season: Spring** — full Spring shift with traffic generation and conditions
- [ ] **Emergency cards** — medevac and SAR with time-based pressure
- [ ] **Remaining seasons** — Summer, Fall, Winter with their specific traffic and escalation
- [ ] **Logbook** — persistent across sessions using Playdate datastore
- [ ] **Weird escalation** — strange callsigns, logbook callbacks, season-specific events
- [ ] **Polish** — sound, animation, title screen, season select

---

## Contributing

### Setup

```bash
make install  # install dev dependencies and git hooks (macOS/Linux)
```

`make install` handles Lua, LuaRocks, luacheck, busted, StyLua, and jq. The [Playdate SDK](https://play.date/dev/) must be installed separately for `make build` and `make sim`.

### Commands

```
make help          # see all targets
make test          # run test suite (busted)
make lint          # run static analysis (luacheck)
make format        # format code with stylua
make format-check  # check formatting without changes
make build         # build the .pdx file
make sim           # build and run in simulator
```

### Lua conventions

- **Locals everywhere**: always use `local` for variables and functions. No implicit globals.
- **Module globals (exception)**: Playdate's `import` doesn't return values, so a few shared modules (`Strings`, `Constants`, etc.) assign to named globals instead of returning a table. Declare these in `.luacheckrc` under `globals` and annotate the file with `-- luacheck: globals <Name>`.
- **Module pattern**: most modules return a table. E.g. `local M = {} ... return M` (exception modules use the named-global pattern above).
- **Naming**: `snake_case` for variables/functions, `PascalCase` for module tables (`Aircraft`, `Queue`)
- **No magic numbers**: use `source/constants.lua` for screen dimensions, layout values, and game parameters.
- **Centralised text**: all displayed strings live in `source/strings.lua`. Never hardcode UI text elsewhere.
- **No metatables**: use the tables-as-objects pattern (`Aircraft.new()`) — no `__index` metatable inheritance unless explicitly needed
- **Playdate idioms**: alias `playdate.graphics` as `gfx`. Use `import` not `require`. Keep `playdate.update()` thin — delegate to game module.
- **Formatting**: StyLua handles formatting. 2-space indent, double quotes.
- **Linting**: luacheck catches globals leaks and unused variables.
- **No external libraries**: standard Playdate SDK only.

### CI

Pull requests are checked with luacheck, StyLua, busted, and `pdc` (Playdate SDK build). Run `make test`, `make lint`, and `make format-check` locally before pushing.
