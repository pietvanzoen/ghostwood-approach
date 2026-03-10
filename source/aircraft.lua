-- Aircraft module: pure Lua, no SDK dependency — fully unit-testable.
-- Represents a single aircraft in the shift queue.

-- luacheck: globals Aircraft
Aircraft = {}

-- Creates a new aircraft record.
-- fuel is in seconds (e.g. 90 = 1 min 30 sec remaining).
-- altitude is in feet (e.g. 8000). Static for now; will become landing timer in Milestone 5.
function Aircraft.new(callsign, fuel, altitude, situation)
  return {
    callsign = callsign,
    fuel = fuel,
    fuel_max = fuel, -- original fuel, used for display (e.g. fuel bar)
    altitude = altitude,
    situation = situation,
  }
end

-- Advances time by dt seconds, burning fuel down toward 0.
function Aircraft.tick(aircraft, dt)
  aircraft.fuel = math.max(0, aircraft.fuel - dt)
end

-- Returns true when the aircraft has run out of fuel.
function Aircraft.is_out_of_fuel(aircraft)
  return aircraft.fuel <= 0
end
