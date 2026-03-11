-- Shift module: initialises a new shift state.
-- Pure Lua, no SDK dependency — fully unit-testable.

-- luacheck: globals Shift
Shift = {}

-- Returns a new shift state with an empty queue and the given schedule attached.
function Shift.new(schedule)
  local state = Queue.new(Constants.MAX_LANDING)
  state.schedule = schedule
  state.elapsed = 0
  state.next_arrival = 1
  return state
end
