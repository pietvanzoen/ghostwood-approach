-- Cursor module: manages cursor position on the shift screen.
-- Pure Lua, no SDK dependency — fully unit-testable.

-- luacheck: globals Cursor
Cursor = {}

-- Returns a new cursor positioned at the first holding slot.
function Cursor.new()
  return { section = Constants.SECTION_HOLDING, index = 1 }
end

-- Adjusts cursor after a promote from holding. If holding is now empty, moves cursor
-- to the last landing slot. Otherwise clamps index to the new holding size.
function Cursor.after_promote(cursor, shift_state)
  if #shift_state.holding == 0 then
    cursor.section = Constants.SECTION_LANDING
    cursor.index = #shift_state.landing
  else
    cursor.index = math.min(cursor.index, #shift_state.holding)
  end
end

-- Moves cursor down. Crosses from landing into holding when at the bottom of landing
-- and holding is non-empty. No-op at bottom of holding.
function Cursor.down(cursor, shift_state)
  local cur_list = shift_state[cursor.section]
  if cursor.index < #cur_list then
    cursor.index = cursor.index + 1
  elseif cursor.section == Constants.SECTION_LANDING and #shift_state.holding > 0 then
    cursor.section = Constants.SECTION_HOLDING
    cursor.index = 1
  end
end

-- Moves cursor up. Crosses from holding into landing when at the top of holding
-- and landing is non-empty. No-op at landing[1] or at holding[1] with empty landing.
function Cursor.up(cursor, shift_state)
  if cursor.index > 1 then
    cursor.index = cursor.index - 1
  elseif cursor.section == Constants.SECTION_HOLDING and #shift_state.landing > 0 then
    cursor.section = Constants.SECTION_LANDING
    cursor.index = #shift_state.landing
  end
end
