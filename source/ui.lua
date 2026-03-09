-- UI module: drawing helpers using the Playdate SDK.
-- Depends on Constants and Strings globals (loaded via import in main.lua).

local gfx = playdate.graphics

-- luacheck: globals UI
UI = {}

local card_font = gfx.font.new("fonts/Roobert-11-Mono-Condensed")

-- Formats fuel seconds as M:SS (e.g. 90 → "1:30", 5 → "0:05").
-- Uses ceil so the display holds at the current second until a full
-- second has elapsed, rather than dropping immediately after each frame.
local function format_fuel(seconds)
  local s = math.ceil(seconds)
  return string.format("%d:%02d", math.floor(s / 60), s % 60)
end

-- Draws a value + label pair centred horizontally in a column.
-- value_y and label_y are absolute screen y positions.
local function draw_cell(value, label, center_x, value_y, label_y)
  gfx.drawTextAligned(value, center_x, value_y, kTextAlignment.center)
  gfx.drawTextAligned(label, center_x, label_y, kTextAlignment.center)
end

-- Draws the aircraft card as a flight progress strip:
--
--   ┌──┬─────────────────┬──────────┬──────────────────────┐
--   │▓▓│  CALLSIGN       │  1:30    │  Normal              │
--   │▓▓│  CALLSIGN label │  FUEL    │  STATUS              │
--   └──┴─────────────────┴──────────┴──────────────────────┘
--
-- Three columns separated by vertical dividers. Each column shows
-- a value on the top row and a small label on the bottom row.
function UI.draw_aircraft_card(aircraft)
  local c = Constants.CARD
  local s = Strings.card

  -- Outer border
  gfx.drawRect(c.X, c.Y, c.WIDTH, c.HEIGHT)

  -- Solid left tab (like a physical strip-holder bay)
  gfx.fillRect(c.X, c.Y, c.TAB_WIDTH, c.HEIGHT)

  -- Column dividers
  gfx.drawLine(c.DIV1_X, c.Y, c.DIV1_X, c.Y + c.HEIGHT - 1)
  gfx.drawLine(c.DIV2_X, c.Y, c.DIV2_X, c.Y + c.HEIGHT - 1)

  -- Column centre x positions
  local col1_cx = math.floor((c.X + c.TAB_WIDTH + c.DIV1_X) / 2)
  local col2_cx = math.floor((c.DIV1_X + c.DIV2_X) / 2)
  local col3_cx = math.floor((c.DIV2_X + c.X + c.WIDTH) / 2)

  -- Absolute y positions for value and label rows
  local value_y = c.Y + c.VALUE_Y_OFFSET
  local label_y = c.Y + c.LABEL_Y_OFFSET

  gfx.setFont(card_font)
  draw_cell(aircraft.callsign, s.callsign_label, col1_cx, value_y, label_y)
  draw_cell(format_fuel(aircraft.fuel), s.fuel_label, col2_cx, value_y, label_y)
  draw_cell(aircraft.situation, s.situation_label, col3_cx, value_y, label_y)
  gfx.setFont(gfx.getSystemFont())
end
