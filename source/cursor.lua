-- Cursor module: manages cursor navigation between the landing and holding sections.
-- Pure Lua, no SDK dependency — fully unit-testable.
--
-- The cursor is a table { section = <string>, index = <number> }.
-- All functions mutate the cursor in place (consistent with Queue's pattern of
-- mutating state), rather than returning a new value.

-- luacheck: globals Cursor
Cursor = {}

-- Moves the cursor up one position within its current section.
-- If already at the top of holding and landing has aircraft, crosses into landing
-- (focusing the last/bottom landing card). Otherwise stays in place.
function Cursor.up(cursor, state)
  if cursor.index > 1 then
    cursor.index = cursor.index - 1
  elseif cursor.section == Constants.SECTION_HOLDING and #state.landing > 0 then
    cursor.section = Constants.SECTION_LANDING
    cursor.index = #state.landing
  end
end

-- Moves the cursor down one position within its current section.
-- If already at the bottom of landing and holding has aircraft, crosses into holding
-- (focusing the first/top holding card). Otherwise stays in place.
function Cursor.down(cursor, state)
  local cur_list = state[cursor.section]
  if cursor.index < #cur_list then
    cursor.index = cursor.index + 1
  elseif cursor.section == Constants.SECTION_LANDING and #state.holding > 0 then
    cursor.section = Constants.SECTION_HOLDING
    cursor.index = 1
  end
end

-- Adjusts cursor after an aircraft is removed from the front of the landing queue
-- (i.e. after Queue.land_front). Only takes effect when the cursor is in landing.
--   • Landing emptied, holding has aircraft → shift focus to holding[1].
--   • Both empty → park cursor at index 1 (safe default; nothing to focus).
--   • Landing still has aircraft → clamp index to the new list length.
function Cursor.clamp_after_land(cursor, state)
  if cursor.section ~= Constants.SECTION_LANDING then
    return
  end
  if #state.landing == 0 and #state.holding > 0 then
    cursor.section = Constants.SECTION_HOLDING
    cursor.index = 1
  elseif #state.landing == 0 then
    cursor.index = 1
  else
    cursor.index = math.min(cursor.index, #state.landing)
  end
end

-- Adjusts cursor after a promote (aircraft moved from holding into landing).
-- Only takes effect when the cursor is in holding.
--   • Holding emptied → shift focus to the aircraft just added to the bottom of landing.
--   • Holding still has aircraft → clamp index to the new (shorter) holding list length.
function Cursor.clamp_after_promote(cursor, state)
  if cursor.section ~= Constants.SECTION_HOLDING then
    return
  end
  if #state.holding == 0 then
    cursor.section = Constants.SECTION_LANDING
    cursor.index = #state.landing
  else
    cursor.index = math.min(cursor.index, #state.holding)
  end
end
