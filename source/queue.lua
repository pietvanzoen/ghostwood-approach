-- Queue module: manages the landing and holding lists.
-- Pure Lua, no SDK dependency — fully unit-testable.

-- luacheck: globals Queue
Queue = {}

local MAX_LANDING = 3

-- Returns a new queue state with empty landing and holding lists.
function Queue.new()
  return { landing = {}, holding = {} }
end

-- Moves the aircraft at `index` in holding to the bottom of landing.
-- Returns false (no-op) if index is out of range or landing list is full.
function Queue.promote(state, index)
  if index < 1 or index > #state.holding then
    return false
  end
  if #state.landing >= MAX_LANDING then
    return false
  end
  local aircraft = table.remove(state.holding, index)
  state.landing[#state.landing + 1] = aircraft
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
