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

-- Draws the aircraft card as a single-row flight progress strip at position (x, y).
--
--   ┌──┬────────┬───────────┬──────────┬──────────────────┐
--   │▓▓│  STW4  │ ALT: 3000 │  F: 1:30 │  Normal          │
--   └──┴────────┴───────────┴──────────┴──────────────────┘
--
-- Labels are inline with values; no separate header row.
-- If focused is true, the card border is drawn thicker to indicate selection.
function UI.draw_aircraft_card(aircraft, x, y, focused)
  local c = Constants.CARD

  if focused then
    gfx.setLineWidth(c.FOCUSED_LINE_WIDTH)
  end
  gfx.drawRect(x, y, c.WIDTH, c.HEIGHT)
  gfx.setLineWidth(1)

  -- Solid left tab (like a physical strip-holder bay)
  gfx.fillRect(x, y, c.TAB_WIDTH, c.HEIGHT)

  -- Column dividers
  local div1, div2, div3 = x + c.DIV1_X, x + c.DIV2_X, x + c.DIV3_X
  gfx.drawLine(div1, y, div1, y + c.HEIGHT - 1)
  gfx.drawLine(div2, y, div2, y + c.HEIGHT - 1)
  gfx.drawLine(div3, y, div3, y + c.HEIGHT - 1)

  local text_y = y + c.TEXT_Y_OFFSET
  gfx.setFont(card_font)
  gfx.drawTextAligned(aircraft.callsign, x + c.COL1_CX, text_y, kTextAlignment.center)
  gfx.drawText(Strings.card.altitude_prefix .. tostring(aircraft.altitude), x + c.COL2_X, text_y)
  gfx.drawText(Strings.card.fuel_prefix .. format_fuel(aircraft.fuel), x + c.COL3_X, text_y)
  gfx.drawTextAligned(aircraft.situation, x + c.COL4_CX, text_y, kTextAlignment.center)
  gfx.setFont(gfx.getSystemFont())
end

-- Draws a placeholder line when a section has no aircraft.
local function draw_empty_state(text, y)
  gfx.setFont(card_font)
  gfx.drawTextAligned(text, Constants.SCREEN_WIDTH / 2, y, kTextAlignment.center)
  gfx.setFont(gfx.getSystemFont())
end

-- Draws a section header label centred on screen.
local function draw_section_header(text, y)
  gfx.setFont(card_font)
  gfx.drawTextAligned(text, Constants.SCREEN_WIDTH / 2, y, kTextAlignment.center)
  gfx.setFont(gfx.getSystemFont())
end

-- Draws the full shift screen: LANDING section header + cards, HOLDING section header + cards.
-- cursor is { section = Constants.SECTION_LANDING|SECTION_HOLDING, index = 1 }
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
  if #shift_state.landing == 0 then
    draw_empty_state(Strings.shift.empty_landing, current_y)
    current_y = current_y + card_step
  else
    for i, aircraft in ipairs(shift_state.landing) do
      local focused = cursor.section == c.SECTION_LANDING and cursor.index == i
      UI.draw_aircraft_card(aircraft, c.CARD.X, current_y, focused)
      current_y = current_y + card_step
    end
  end

  -- HOLDING section header
  draw_section_header(Strings.shift.holding_label, current_y)
  current_y = current_y + c.SECTION_HEADER_HEIGHT

  -- Holding cards
  if #shift_state.holding == 0 then
    draw_empty_state(Strings.shift.empty_holding, current_y)
  else
    for i, aircraft in ipairs(shift_state.holding) do
      local focused = cursor.section == c.SECTION_HOLDING and cursor.index == i
      UI.draw_aircraft_card(aircraft, c.CARD.X, current_y, focused)
      current_y = current_y + card_step
    end
  end
end
