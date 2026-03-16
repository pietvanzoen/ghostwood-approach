-- Scoring module: calculates end-of-shift score from landed aircraft.
-- Pure Lua, no SDK dependency — fully unit-testable.

-- luacheck: globals Scoring
Scoring = {}

-- Calculates the score for a completed shift from a list of landed aircraft.
-- Returns { landed_count, avg_fuel_pct, near_miss_count, total }.
--
-- An empty landed list (no aircraft landed) returns total = 0; the base score
-- requires at least one aircraft to have landed.
--
-- Scoring formula (when landed is non-empty):
--   base       = 50  (for landing at least one aircraft)
--   efficiency = floor(50 * avg_fuel_pct)  (0..50, based on average fuel remaining)
--   penalty    = 10 * near_miss_count      (deducted per near-miss landing)
--   total      = max(0, base + efficiency - penalty)
--
-- A "near miss" is any aircraft that landed with fuel < CRITICAL_FUEL_PCT of its starting fuel.
function Scoring.calculate(landed)
  local n = #landed
  if n == 0 then
    return { landed_count = 0, avg_fuel_pct = 0, near_miss_count = 0, total = 0 }
  end

  local fuel_pct_sum = 0
  local near_miss_count = 0
  for _, aircraft in ipairs(landed) do
    local pct = aircraft.fuel / aircraft.fuel_max
    fuel_pct_sum = fuel_pct_sum + pct
    if pct < Constants.CRITICAL_FUEL_PCT then
      near_miss_count = near_miss_count + 1
    end
  end

  local avg_fuel_pct = fuel_pct_sum / n
  local base = 50
  local efficiency = math.floor(50 * avg_fuel_pct)
  local penalty = 10 * near_miss_count
  local total = math.max(0, base + efficiency - penalty)

  return {
    landed_count = n,
    avg_fuel_pct = avg_fuel_pct,
    near_miss_count = near_miss_count,
    total = total,
  }
end
