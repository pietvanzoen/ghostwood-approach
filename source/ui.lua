-- UI module: drawing helpers using the Playdate SDK.
-- Depends on Constants and Strings globals (loaded via import in main.lua).

local gfx = playdate.graphics

-- luacheck: globals UI
UI = {}

local card_font = gfx.font.new("fonts/Roobert-9-Mono-Condensed")

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

-- Draws the aircraft card as a flight progress strip at position (x, y).
--
--   ┌──┬──────────┬────────┬────────┬──────────────────┐
--   │▓▓│ CALLSIGN │  8000  │  1:30  │  Normal          │
--   │▓▓│ CALLSIGN │  ALT   │  FUEL  │  STATUS          │
--   └──┴──────────┴────────┴────────┴──────────────────┘
--
-- Four columns separated by vertical dividers. Each column shows
-- a value on the top row and a small label on the bottom row.
-- If focused is true, the card is drawn with an inverted tab and border highlight.
function UI.draw_aircraft_card(aircraft, x, y, focused)
  local c = Constants.CARD
  local s = Strings.card

  if focused then
    -- Highlighted border
    gfx.setLineWidth(2)
    gfx.drawRect(x, y, c.WIDTH, c.HEIGHT)
    gfx.setLineWidth(1)
    -- Inverted tab (white text on black background)
    gfx.fillRect(x, y, c.TAB_WIDTH, c.HEIGHT)
  else
    gfx.drawRect(x, y, c.WIDTH, c.HEIGHT)
    gfx.fillRect(x, y, c.TAB_WIDTH, c.HEIGHT)
  end

  -- Column dividers
  gfx.drawLine(c.DIV1_X, y, c.DIV1_X, y + c.HEIGHT - 1)
  gfx.drawLine(c.DIV2_X, y, c.DIV2_X, y + c.HEIGHT - 1)
  gfx.drawLine(c.DIV3_X, y, c.DIV3_X, y + c.HEIGHT - 1)

  -- Column centre x positions
  local col1_cx = math.floor((x + c.TAB_WIDTH + c.DIV1_X) / 2)
  local col2_cx = math.floor((c.DIV1_X + c.DIV2_X) / 2)
  local col3_cx = math.floor((c.DIV2_X + c.DIV3_X) / 2)
  local col4_cx = math.floor((c.DIV3_X + x + c.WIDTH) / 2)

  -- Absolute y positions for value and label rows
  local value_y = y + c.VALUE_Y_OFFSET
  local label_y = y + c.LABEL_Y_OFFSET

  gfx.setFont(card_font)
  draw_cell(aircraft.callsign, s.callsign_label, col1_cx, value_y, label_y)
  draw_cell(tostring(aircraft.altitude), s.altitude_label, col2_cx, value_y, label_y)
  draw_cell(format_fuel(aircraft.fuel), s.fuel_label, col3_cx, value_y, label_y)
  draw_cell(aircraft.situation, s.situation_label, col4_cx, value_y, label_y)
  gfx.setFont(gfx.getSystemFont())
end

-- Draws a section header label centred on screen.
local function draw_section_header(text, y)
  gfx.setFont(card_font)
  gfx.drawTextAligned(text, Constants.SCREEN_WIDTH / 2, y, kTextAlignment.center)
  gfx.setFont(gfx.getSystemFont())
end

-- Draws the full shift screen: LANDING section header + cards, HOLDING section header + cards.
-- cursor is { section = "landing"|"holding", index = 1 }
function UI.draw_shift_screen(shift_state, cursor)
  local c = Constants
  gfx.clear(gfx.kColorWhite)

  local card_step = c.CARD.HEIGHT + c.CARD.CARD_GAP
  local current_y = c.CARD_LIST_START_Y

  -- LANDING section header
  local landing_count = #shift_state.landing
  local landing_header = string.format("%s %d/%d", Strings.shift.landing_label, landing_count, c.MAX_LANDING)
  draw_section_header(landing_header, current_y)
  current_y = current_y + c.SECTION_HEADER_HEIGHT

  -- Landing cards
  for i, aircraft in ipairs(shift_state.landing) do
    local focused = cursor.section == "landing" and cursor.index == i
    UI.draw_aircraft_card(aircraft, c.CARD.X, current_y, focused)
    current_y = current_y + card_step
  end

  -- HOLDING section header
  draw_section_header(Strings.shift.holding_label, current_y)
  current_y = current_y + c.SECTION_HEADER_HEIGHT

  -- Holding cards
  for i, aircraft in ipairs(shift_state.holding) do
    local focused = cursor.section == "holding" and cursor.index == i
    UI.draw_aircraft_card(aircraft, c.CARD.X, current_y, focused)
    current_y = current_y + card_step
  end
end
