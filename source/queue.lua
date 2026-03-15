-- Queue module: manages the landing and holding lists.
-- Pure Lua, no SDK dependency — fully unit-testable.

-- luacheck: globals Queue
Queue = {}

-- Returns a new queue state with empty landing and holding lists.
-- max_landing caps how many aircraft can be in the landing list (default 3).
-- schedule and next_arrival are initialised to safe defaults so check_arrivals
-- can be called on a fresh queue without error.
-- landed accumulates aircraft that have touched down, for use in scoring.
function Queue.new(max_landing)
  return { landing = {}, holding = {}, landed = {}, max_landing = max_landing or 3, schedule = {}, next_arrival = 1 }
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

-- Removes the front of the landing queue when its altitude reaches 0 (touchdown).
-- Appends the landed aircraft to state.landed for later scoring.
-- Returns the aircraft on success, nil if landing is empty.
function Queue.land_front(state)
  if #state.landing == 0 then
    return nil
  end
  local aircraft = table.remove(state.landing, 1)
  state.landed[#state.landed + 1] = aircraft
  return aircraft
end

-- Manages the touchdown dwell for the front landing aircraft.
-- When the front aircraft reaches altitude 0, starts a TOUCHDOWN_DWELL-second timer.
-- Counts the timer down each tick; when it expires, calls land_front to clear the runway.
-- Returns true if land_front was called this tick (so the caller can adjust the cursor),
-- false in all other cases (no aircraft, still descending, dwell not yet expired).
function Queue.resolve_touchdown(state, dt)
  if #state.landing == 0 or state.landing[1].altitude > 0 then
    return false
  end
  local front = state.landing[1]
  if front.touchdown_timer == nil then
    -- Aircraft just touched down: start the dwell timer.
    front.touchdown_timer = Constants.TOUCHDOWN_DWELL
    return false
  end
  front.touchdown_timer = front.touchdown_timer - dt
  if front.touchdown_timer <= 0 then
    Queue.land_front(state)
    return true
  end
  return false
end

-- Advances time by dt seconds for every aircraft in both lists.
-- Aircraft in the landing queue also lose altitude at Constants.APPROACH_RATE ft/sec,
-- simulating the approach descent. Holding aircraft maintain their assigned altitude.
-- Landing aircraft only descend if there is at least MIN_LANDING_SEP feet of separation
-- from the aircraft ahead, preventing visual confusion from multiple aircraft descending
-- at nearly the same altitude.
function Queue.tick_all(state, dt)
  for i, aircraft in ipairs(state.landing) do
    Aircraft.tick(aircraft, dt)
    local prev = state.landing[i - 1]
    -- Only descend if there is enough gap from the aircraft ahead,
    -- or if this is the first in the queue.
    if prev == nil or aircraft.altitude - prev.altitude >= Constants.MIN_LANDING_SEP then
      aircraft.altitude = math.max(0, aircraft.altitude - Constants.APPROACH_RATE * dt)
    end
  end
  for _, aircraft in ipairs(state.holding) do
    Aircraft.tick(aircraft, dt)
    -- Holding: aircraft circle at their assigned altitude, no descent.
  end
end
