-- Queue module: manages the landing and holding lists.
-- Pure Lua, no SDK dependency — fully unit-testable.

-- luacheck: globals Queue
Queue = {}

-- Returns a new queue state with empty landing and holding lists.
-- max_landing caps how many aircraft can be in the landing list (default 3).
-- schedule and next_arrival are initialised to safe defaults so check_arrivals
-- can be called on a fresh queue without error.
function Queue.new(max_landing)
  return { landing = {}, holding = {}, max_landing = max_landing or 3, schedule = {}, next_arrival = 1 }
end

-- Moves the aircraft at `index` in holding to the bottom of landing.
-- Returns true on success, false if index is out of range or landing list is full.
function Queue.promote(state, index)
  if index < 1 or index > #state.holding then
    return false
  end
  if #state.landing >= state.max_landing then
    return false
  end
  local aircraft = table.remove(state.holding, index)
  state.landing[#state.landing + 1] = aircraft
  return true
end

-- Appends any scheduled aircraft whose arrival time <= elapsed to holding.
-- state.schedule: sorted array of { time = <seconds>, aircraft = <Aircraft> }
-- state.next_arrival: index of the next unprocessed schedule entry (starts at 1)
function Queue.check_arrivals(state, elapsed)
  while state.next_arrival <= #state.schedule do
    local entry = state.schedule[state.next_arrival]
    if entry.time <= elapsed then
      state.holding[#state.holding + 1] = entry.aircraft
      state.next_arrival = state.next_arrival + 1
    else
      break -- schedule is sorted, no need to look further
    end
  end
end

-- Advances time by dt seconds for every aircraft in both lists.
function Queue.tick_all(state, dt)
  for _, aircraft in ipairs(state.landing) do
    Aircraft.tick(aircraft, dt)
  end
  for _, aircraft in ipairs(state.holding) do
    Aircraft.tick(aircraft, dt)
  end
end
