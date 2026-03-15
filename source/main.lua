-- Stillwater Approach
-- Entry point for the Playdate game

-- Debug logging: set to false before release to silence all log() calls
local DEBUG <const> = true

-- luacheck: globals log
function log(...)
  if DEBUG then
    print(...)
  end
end

import("CoreLibs/graphics")
import("strings")
import("constants")
import("aircraft")
import("queue")
import("cursor")
import("ui")
import("cover")

local gfx <const> = playdate.graphics

-- Screen states
local STATE_TITLE = "title"
local STATE_SHIFT = "shift"

local state = STATE_TITLE

-- Shift state: queue of landing and holding aircraft, cursor position, and last frame timestamp
local shift_state = nil -- { landing = {}, holding = {} }
local cursor = nil -- { section = Constants.SECTION_LANDING|SECTION_HOLDING, index = 1 }
local last_time = nil

-- Title screen: shows tower-centric cover art with prompt to start
local function draw_title()
  Cover.draw()
  gfx.setColor(gfx.kColorBlack)
  gfx.drawTextAligned(Strings.title.prompt, Constants.SCREEN_CENTER_X, Constants.TITLE_PROMPT_Y, kTextAlignment.center)
end

-- Handles d-pad and A button input during a shift.
local function handle_shift_input()
  if playdate.buttonJustPressed(playdate.kButtonUp) then
    Cursor.up(cursor, shift_state)
  elseif playdate.buttonJustPressed(playdate.kButtonDown) then
    Cursor.down(cursor, shift_state)
  elseif playdate.buttonJustPressed(playdate.kButtonA) then
    if cursor.section == Constants.SECTION_HOLDING then
      Queue.promote(shift_state, cursor.index)
      Cursor.clamp_after_promote(cursor, shift_state)
    end
    -- A on landing card: no-op
  end
end

-- Shift screen: tick fuel on all aircraft, handle arrivals, handle input, redraw
local function update_shift()
  local now = playdate.getCurrentTimeMilliseconds()
  local dt = (now - last_time) / 1000.0
  last_time = now

  shift_state.elapsed = shift_state.elapsed + dt
  Queue.check_arrivals(shift_state, shift_state.elapsed)
  Queue.tick_all(shift_state, dt)

  -- Landing resolution: manage touchdown dwell and runway clearing.
  -- Returns true when land_front is called so we can keep the cursor valid.
  local landed = Queue.resolve_touchdown(shift_state, dt)
  if landed then
    Cursor.clamp_after_land(cursor, shift_state)
  end

  handle_shift_input()
  UI.draw_shift_screen(shift_state, cursor)
end

function playdate.update()
  if state == STATE_TITLE then
    draw_title()
    if playdate.buttonJustPressed(playdate.kButtonA) then
      -- Initialise shift with timed arrivals; landing and holding start empty
      shift_state = Queue.new(Constants.MAX_LANDING)
      shift_state.elapsed = 0
      -- Altitudes are AGL (feet above the runway). Holding aircraft maintain these altitudes
      -- until promoted to the landing queue, at which point they descend to 0 (touchdown).
      -- Values reflect realistic KSTW holding stack: 2500/3500/4500 ft AGL in 1000 ft increments.
      shift_state.schedule = {
        { time = 0, aircraft = Aircraft.new("STW4", 90, 2500, "Normal") },
        { time = 15, aircraft = Aircraft.new("SVC12", 120, 3500, "Cargo Shift") },
        { time = 40, aircraft = Aircraft.new("TNK81", 75, 2500, "Low Fuel") },
        { time = 70, aircraft = Aircraft.new("QUL3", 140, 4500, "Normal") },
        { time = 100, aircraft = Aircraft.new("CAM1", 60, 3000, "Medical") },
        { time = 130, aircraft = Aircraft.new("PTA7", 110, 4000, "Normal") },
      }
      shift_state.next_arrival = 1
      cursor = { section = Constants.SECTION_HOLDING, index = 1 }
      last_time = playdate.getCurrentTimeMilliseconds()
      state = STATE_SHIFT
    end
  elseif state == STATE_SHIFT then
    update_shift()
  end
end
