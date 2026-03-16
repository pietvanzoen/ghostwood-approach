-- Tests for the Scoring module.
-- Constants and Scoring must be required explicitly (not available automatically in busted).
-- luacheck: globals Scoring
require("source.constants")
require("source.scoring")

describe("Scoring.calculate", function()
  -- Helper to create a minimal landed aircraft record
  local function make_aircraft(fuel, fuel_max)
    return { fuel = fuel, fuel_max = fuel_max }
  end

  it("returns zeros for an empty landed list", function()
    local result = Scoring.calculate({})
    assert.are.equal(0, result.landed_count)
    assert.are.equal(0, result.avg_fuel_pct)
    assert.are.equal(0, result.near_miss_count)
    assert.are.equal(0, result.total)
  end)

  it("scores 100 when all aircraft land with full fuel", function()
    -- fuel == fuel_max → avg_fuel_pct = 1.0
    -- base(50) + efficiency(50) - penalty(0) = 100
    local landed = {
      make_aircraft(90, 90),
      make_aircraft(120, 120),
    }
    local result = Scoring.calculate(landed)
    assert.are.equal(2, result.landed_count)
    assert.are.equal(0, result.near_miss_count)
    assert.are.equal(100, result.total)
  end)

  it("applies near-miss penalties when all aircraft land on empty tanks", function()
    -- fuel = 0 → fuel_pct = 0.0 < CRITICAL_FUEL_PCT (0.1) → each counts as a near miss
    -- base(50) + efficiency(0) - penalty(2 * 10) = 30
    local landed = {
      make_aircraft(0, 90),
      make_aircraft(0, 120),
    }
    local result = Scoring.calculate(landed)
    assert.are.equal(2, result.near_miss_count)
    assert.are.equal(30, result.total)
  end)

  it("counts a near miss when fuel is below 10% of fuel_max", function()
    -- 8/90 ≈ 0.089 < 0.1 → near miss
    local landed = { make_aircraft(8, 90) }
    local result = Scoring.calculate(landed)
    assert.are.equal(1, result.near_miss_count)
  end)

  it("does not count a near miss when fuel is exactly at 10% of fuel_max", function()
    -- 9/90 = 0.1, not < 0.1
    local landed = { make_aircraft(9, 90) }
    local result = Scoring.calculate(landed)
    assert.are.equal(0, result.near_miss_count)
  end)

  it("clamps total score to 0 when penalties exceed base + efficiency", function()
    -- Many near misses: 10 aircraft with 0 fuel → 10 near misses
    -- base(50) + efficiency(0) - penalty(100) = -50 → clamped to 0
    local landed = {}
    for _ = 1, 10 do
      landed[#landed + 1] = make_aircraft(0, 90)
    end
    local result = Scoring.calculate(landed)
    assert.are.equal(0, result.total)
  end)

  it("computes avg_fuel_pct across all aircraft", function()
    -- Aircraft 1: 90/90 = 1.0, Aircraft 2: 45/90 = 0.5 → avg = 0.75
    local landed = {
      make_aircraft(90, 90),
      make_aircraft(45, 90),
    }
    local result = Scoring.calculate(landed)
    assert.are.near(0.75, result.avg_fuel_pct, 0.001)
    -- base(50) + floor(50 * 0.75) = 50 + 37 = 87
    assert.are.equal(87, result.total)
  end)
end)
