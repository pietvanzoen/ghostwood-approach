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
--   ┌──┬────────┬───────────┬──────────┬──────────────────┐
--   │▓▓│  STW4  │ ALTv 2450 │  F: 1:15 │  Normal          │  ← on approach
--   └──┴────────┴───────────┴──────────┴──────────────────┘
--
-- Labels are inline with values; no separate header row.
-- If focused is true, the card border is drawn thicker to indicate selection.
-- If on_approach is true, the altitude label shows a down-arrow (v) to signal
-- the value is counting toward 0 (touchdown). Holding cards use the plain "ALT: " label.
function UI.draw_aircraft_card(aircraft, x, y, focused, on_approach)
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

  -- Altitude label: "ALTv " on approach (descending), "ALT: " in holding (static).
  -- On approach: round to tens so display changes every ~0.2s instead of every frame.
  local alt_prefix = on_approach and Strings.card.altitude_approach_prefix or Strings.card.altitude_prefix
  local alt_value = on_approach and (math.ceil(aircraft.altitude / 10) * 10) or math.ceil(aircraft.altitude)
  gfx.drawText(alt_prefix .. tostring(alt_value), x + c.COL2_X, text_y)

  gfx.drawText(Strings.card.fuel_prefix .. format_fuel(aircraft.fuel), x + c.COL3_X, text_y)
  local situation_text = aircraft.touchdown_timer ~= nil and Strings.card.landed or aircraft.situation
  gfx.drawTextAligned(situation_text, x + c.COL4_CX, text_y, kTextAlignment.center)
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

-- Draws the end-of-shift score screen.
-- result is the table returned by Scoring.calculate, plus:
--   win             (boolean) true = shift complete, false = shift failed
--   failed_callsign (string|nil) callsign of aircraft that ran out of fuel (lose only)
function UI.draw_score_screen(result)
  -- Layout constants for the score screen
  local MARGIN_X = 10 -- horizontal margin for divider lines
  local LABEL_X = 40 -- left edge of stat labels
  local VALUE_X = Constants.SCREEN_WIDTH - 40 -- right edge of stat values
  local TOP_Y = 20 -- y of the heading
  local HEADING_H = 18 -- vertical space below heading
  local DIVIDER_H = 8 -- vertical space after a divider line
  local FAIL_ROW_H = 14 -- vertical space for the failure callsign row
  local ROW_H = 14 -- height of each stat row
  local EXTRA_GAP = 4 -- extra gap before the total divider
  local PROMPT_Y = Constants.SCREEN_HEIGHT - 20 -- y of the "press A" prompt

  gfx.clear(gfx.kColorWhite)
  gfx.setFont(card_font)

  local cx = Constants.SCREEN_CENTER_X
  local y = TOP_Y

  -- Heading: "SHIFT COMPLETE" or "SHIFT FAILED"
  local heading = result.win and Strings.score.win_heading or Strings.score.lose_heading
  gfx.drawTextAligned(heading, cx, y, kTextAlignment.center)
  y = y + HEADING_H

  -- Divider
  gfx.drawLine(MARGIN_X, y, Constants.SCREEN_WIDTH - MARGIN_X, y)
  y = y + DIVIDER_H

  -- On a failed shift, show which aircraft caused the failure
  if not result.win and result.failed_callsign then
    local msg = result.failed_callsign .. " " .. Strings.score.out_of_fuel
    gfx.drawTextAligned(msg, cx, y, kTextAlignment.center)
    y = y + FAIL_ROW_H
  end

  -- Stats: label left-aligned, value right-aligned
  gfx.drawText(Strings.score.landed_label, LABEL_X, y)
  gfx.drawTextAligned(tostring(result.landed_count), VALUE_X, y, kTextAlignment.right)
  y = y + ROW_H

  -- Efficiency as a percentage (0–100%)
  local eff_pct = math.floor(result.avg_fuel_pct * 100)
  gfx.drawText(Strings.score.efficiency_label, LABEL_X, y)
  gfx.drawTextAligned(tostring(eff_pct) .. "%", VALUE_X, y, kTextAlignment.right)
  y = y + ROW_H

  gfx.drawText(Strings.score.near_miss_label, LABEL_X, y)
  gfx.drawTextAligned(tostring(result.near_miss_count), VALUE_X, y, kTextAlignment.right)
  y = y + ROW_H + EXTRA_GAP

  -- Divider above score total
  gfx.drawLine(MARGIN_X, y, Constants.SCREEN_WIDTH - MARGIN_X, y)
  y = y + DIVIDER_H

  gfx.drawText(Strings.score.score_label, LABEL_X, y)
  gfx.drawTextAligned(tostring(result.total), VALUE_X, y, kTextAlignment.right)

  -- Prompt at bottom
  gfx.drawTextAligned(Strings.score.prompt, cx, PROMPT_Y, kTextAlignment.center)

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
      UI.draw_aircraft_card(aircraft, c.CARD.X, current_y, focused, true)
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
