require("source.constants")
require("source.aircraft")
require("source.queue")

-- Helper: creates a minimal aircraft stub with a fuel value.
local function make_aircraft(callsign, fuel)
  return Aircraft.new(callsign, fuel, 8000, "Normal")
end

describe("Queue", function()
  describe("Queue.new", function()
    it("returns table with empty landing list", function()
      local q = Queue.new()
      assert.same({}, q.landing)
    end)

    it("returns table with empty holding list", function()
      local q = Queue.new()
      assert.same({}, q.holding)
    end)
  end)

  describe("Queue.promote", function()
    it("returns true on success", function()
      local q = Queue.new()
      q.holding[1] = make_aircraft("GA4", 90)
      assert.is_true(Queue.promote(q, 1))
    end)

    it("appends aircraft to bottom of landing", function()
      local q = Queue.new()
      local a = make_aircraft("GA4", 90)
      q.holding[1] = a
      Queue.promote(q, 1)
      assert.equal(a, q.landing[1])
    end)

    it("removes aircraft from holding", function()
      local q = Queue.new()
      q.holding[1] = make_aircraft("GA4", 90)
      Queue.promote(q, 1)
      assert.equal(0, #q.holding)
    end)

    it("preserves order of remaining holding entries", function()
      local q = Queue.new()
      local a1 = make_aircraft("GA4", 90)
      local a2 = make_aircraft("SVC1", 60)
      local a3 = make_aircraft("TK81", 75)
      q.holding = { a1, a2, a3 }
      Queue.promote(q, 1)
      assert.equal(a2, q.holding[1])
      assert.equal(a3, q.holding[2])
    end)

    it("returns false for out-of-range index", function()
      local q = Queue.new()
      q.holding[1] = make_aircraft("GA4", 90)
      assert.is_false(Queue.promote(q, 5))
    end)

    it("does not modify state when index is out of range", function()
      local q = Queue.new()
      local a = make_aircraft("GA4", 90)
      q.holding[1] = a
      Queue.promote(q, 5)
      assert.equal(1, #q.holding)
      assert.equal(0, #q.landing)
    end)

    it("returns false when landing list is full", function()
      local q = Queue.new(3)
      q.landing = { make_aircraft("A", 90), make_aircraft("B", 90), make_aircraft("C", 90) }
      q.holding[1] = make_aircraft("D", 90)
      assert.is_false(Queue.promote(q, 1))
    end)

    it("does not modify state when landing list is full", function()
      local q = Queue.new(3)
      local a1, a2, a3 = make_aircraft("A", 90), make_aircraft("B", 90), make_aircraft("C", 90)
      local a4 = make_aircraft("D", 90)
      q.landing = { a1, a2, a3 }
      q.holding = { a4 }
      Queue.promote(q, 1)
      assert.equal(3, #q.landing)
      assert.equal(1, #q.holding)
    end)
  end)

  describe("Queue.check_arrivals", function()
    it("does not add aircraft before their scheduled time", function()
      local q = Queue.new()
      q.schedule = { { time = 10, aircraft = make_aircraft("GA4", 90) } }
      q.next_arrival = 1
      Queue.check_arrivals(q, 5)
      assert.equal(0, #q.holding)
    end)

    it("adds aircraft with time = 0 at elapsed = 0", function()
      local q = Queue.new()
      local a = make_aircraft("GA4", 90)
      q.schedule = { { time = 0, aircraft = a } }
      q.next_arrival = 1
      Queue.check_arrivals(q, 0)
      assert.equal(1, #q.holding)
      assert.equal(a, q.holding[1])
    end)

    it("adds all aircraft sharing the same arrival time together", function()
      local q = Queue.new()
      local a1 = make_aircraft("GA4", 90)
      local a2 = make_aircraft("SVC1", 60)
      q.schedule = { { time = 5, aircraft = a1 }, { time = 5, aircraft = a2 } }
      q.next_arrival = 1
      Queue.check_arrivals(q, 5)
      assert.equal(2, #q.holding)
    end)

    it("adds aircraft at exactly their scheduled time", function()
      local q = Queue.new()
      local a = make_aircraft("GA4", 90)
      q.schedule = { { time = 10, aircraft = a } }
      q.next_arrival = 1
      Queue.check_arrivals(q, 9)
      assert.equal(0, #q.holding)
      Queue.check_arrivals(q, 10)
      assert.equal(1, #q.holding)
      assert.equal(a, q.holding[1])
    end)

    it("does not re-add aircraft when called again with the same elapsed", function()
      local q = Queue.new()
      local a = make_aircraft("GA4", 90)
      q.schedule = { { time = 5, aircraft = a } }
      q.next_arrival = 1
      Queue.check_arrivals(q, 5)
      Queue.check_arrivals(q, 5)
      assert.equal(1, #q.holding)
    end)

    it("advances next_arrival past spawned entries and leaves future ones", function()
      local q = Queue.new()
      local a1 = make_aircraft("GA4", 90)
      local a2 = make_aircraft("SVC1", 60)
      q.schedule = { { time = 5, aircraft = a1 }, { time = 20, aircraft = a2 } }
      q.next_arrival = 1
      Queue.check_arrivals(q, 10)
      assert.equal(1, #q.holding)
      assert.equal(a1, q.holding[1])
      assert.equal(2, q.next_arrival)
    end)
  end)

  describe("Queue.land_front", function()
    it("returns nil when landing is empty", function()
      local q = Queue.new()
      assert.is_nil(Queue.land_front(q))
    end)

    it("returns the first aircraft", function()
      local q = Queue.new()
      local a = make_aircraft("STW4", 90)
      q.landing = { a }
      assert.equal(a, Queue.land_front(q))
    end)

    it("removes the first aircraft from landing", function()
      local q = Queue.new()
      q.landing = { make_aircraft("STW4", 90) }
      Queue.land_front(q)
      assert.equal(0, #q.landing)
    end)

    it("appends the aircraft to state.landed", function()
      local q = Queue.new()
      local a = make_aircraft("STW4", 90)
      q.landing = { a }
      Queue.land_front(q)
      assert.equal(1, #q.landed)
      assert.equal(a, q.landed[1])
    end)

    it("preserves order of remaining landing aircraft", function()
      local q = Queue.new()
      local a1 = make_aircraft("STW4", 90)
      local a2 = make_aircraft("SVC12", 120)
      local a3 = make_aircraft("TNK81", 75)
      q.landing = { a1, a2, a3 }
      Queue.land_front(q)
      assert.equal(a2, q.landing[1])
      assert.equal(a3, q.landing[2])
    end)

    it("does not touch the holding list", function()
      local q = Queue.new()
      local hold = make_aircraft("QUL3", 140)
      q.landing = { make_aircraft("STW4", 90) }
      q.holding = { hold }
      Queue.land_front(q)
      assert.equal(1, #q.holding)
      assert.equal(hold, q.holding[1])
    end)
  end)

  describe("Queue.resolve_touchdown", function()
    it("returns false when landing is empty", function()
      local q = Queue.new()
      assert.is_false(Queue.resolve_touchdown(q, 1))
    end)

    it("returns false when front aircraft altitude is above 0", function()
      local q = Queue.new()
      local a = make_aircraft("STW4", 90)
      a.altitude = 100
      q.landing = { a }
      assert.is_false(Queue.resolve_touchdown(q, 1))
    end)

    it("sets touchdown_timer to TOUCHDOWN_DWELL when aircraft first reaches altitude 0", function()
      local q = Queue.new()
      local a = make_aircraft("STW4", 90)
      a.altitude = 0
      q.landing = { a }
      Queue.resolve_touchdown(q, 1)
      assert.equal(Constants.TOUCHDOWN_DWELL, a.touchdown_timer)
    end)

    it("returns false on the first tick at altitude 0 (dwell not yet expired)", function()
      local q = Queue.new()
      local a = make_aircraft("STW4", 90)
      a.altitude = 0
      q.landing = { a }
      assert.is_false(Queue.resolve_touchdown(q, 1))
    end)

    it("counts down the dwell timer each tick", function()
      local q = Queue.new()
      local a = make_aircraft("STW4", 90)
      a.altitude = 0
      q.landing = { a }
      Queue.resolve_touchdown(q, 0) -- initialises timer to TOUCHDOWN_DWELL
      Queue.resolve_touchdown(q, 1) -- counts down by 1
      assert.equal(Constants.TOUCHDOWN_DWELL - 1, a.touchdown_timer)
    end)

    it("does not remove aircraft while dwell timer is still positive", function()
      local q = Queue.new()
      local a = make_aircraft("STW4", 90)
      a.altitude = 0
      q.landing = { a }
      Queue.resolve_touchdown(q, 0) -- start timer
      Queue.resolve_touchdown(q, Constants.TOUCHDOWN_DWELL - 0.5) -- nearly expired
      assert.equal(1, #q.landing)
    end)

    it("calls land_front and returns true when dwell timer expires", function()
      local q = Queue.new()
      local a = make_aircraft("STW4", 90)
      a.altitude = 0
      q.landing = { a }
      Queue.resolve_touchdown(q, 0) -- start timer
      local result = Queue.resolve_touchdown(q, Constants.TOUCHDOWN_DWELL)
      assert.is_true(result)
      assert.equal(0, #q.landing)
      assert.equal(1, #q.landed)
    end)

    it("does not affect the holding list", function()
      local q = Queue.new()
      local hold = make_aircraft("QUL3", 140)
      local a = make_aircraft("STW4", 90)
      a.altitude = 0
      q.landing = { a }
      q.holding = { hold }
      Queue.resolve_touchdown(q, 0)
      Queue.resolve_touchdown(q, Constants.TOUCHDOWN_DWELL)
      assert.equal(1, #q.holding)
      assert.equal(hold, q.holding[1])
    end)
  end)

  describe("Queue.tick_all", function()
    it("ticks all aircraft in landing by dt", function()
      local q = Queue.new()
      local a1 = make_aircraft("A", 90)
      local a2 = make_aircraft("B", 60)
      q.landing = { a1, a2 }
      Queue.tick_all(q, 10)
      assert.equal(80, a1.fuel)
      assert.equal(50, a2.fuel)
    end)

    it("ticks all aircraft in holding by dt", function()
      local q = Queue.new()
      local a1 = make_aircraft("A", 90)
      local a2 = make_aircraft("B", 60)
      q.holding = { a1, a2 }
      Queue.tick_all(q, 10)
      assert.equal(80, a1.fuel)
      assert.equal(50, a2.fuel)
    end)

    it("decreases altitude for landing aircraft by APPROACH_RATE * dt", function()
      local q = Queue.new()
      local a = make_aircraft("A", 90)
      a.altitude = 2500
      q.landing = { a }
      Queue.tick_all(q, 1)
      -- APPROACH_RATE = 50, dt = 1 → 2500 - 50 = 2450
      assert.equal(2450, a.altitude)
    end)

    it("clamps landing altitude at 0, never negative", function()
      local q = Queue.new()
      local a = make_aircraft("A", 90)
      a.altitude = 10
      q.landing = { a }
      Queue.tick_all(q, 10) -- would be 10 - 500 = -490 without clamp
      assert.equal(0, a.altitude)
    end)

    it("does not change altitude for holding aircraft", function()
      local q = Queue.new()
      local a = make_aircraft("A", 90)
      a.altitude = 3500
      q.holding = { a }
      Queue.tick_all(q, 10)
      assert.equal(3500, a.altitude)
    end)

    it("aircraft at position 1 always descends", function()
      local q = Queue.new()
      local a = make_aircraft("A", 90)
      a.altitude = 2500
      q.landing = { a }
      Queue.tick_all(q, 1)
      -- Position 1 has no aircraft ahead, so it descends normally
      assert.equal(2450, a.altitude)
    end)

    it("aircraft at position 2 does not descend when gap is less than MIN_LANDING_SEP", function()
      local q = Queue.new()
      local a1 = make_aircraft("A", 90)
      a1.altitude = 2500
      local a2 = make_aircraft("B", 80)
      a2.altitude = 2550 -- gap = 50, less than MIN_LANDING_SEP (500)
      q.landing = { a1, a2 }
      Queue.tick_all(q, 1)
      -- a1 descends: 2500 - 50 = 2450
      assert.equal(2450, a1.altitude)
      -- a2 is held: gap would have been 50, stays 2550
      assert.equal(2550, a2.altitude)
    end)

    it("aircraft at position 2 descends once gap to position 1 reaches MIN_LANDING_SEP", function()
      local q = Queue.new()
      local a1 = make_aircraft("A", 90)
      a1.altitude = 2000
      local a2 = make_aircraft("B", 80)
      a2.altitude = 2500 -- gap = 500, exactly MIN_LANDING_SEP
      q.landing = { a1, a2 }
      Queue.tick_all(q, 1)
      -- a1 descends: 2000 - 50 = 1950
      assert.equal(1950, a1.altitude)
      -- a2 gap is exactly 500, so it can descend: 2500 - 50 = 2450
      assert.equal(2450, a2.altitude)
    end)

    it("enforces separation between all aircraft in landing queue", function()
      local q = Queue.new()
      local a1 = make_aircraft("A", 90)
      a1.altitude = 1500
      local a2 = make_aircraft("B", 80)
      a2.altitude = 2100 -- gap = 600, > MIN_LANDING_SEP
      local a3 = make_aircraft("C", 70)
      a3.altitude = 2400 -- gap from a2 = 300, < MIN_LANDING_SEP
      q.landing = { a1, a2, a3 }
      Queue.tick_all(q, 1)
      -- a1 descends: 1500 - 50 = 1450
      assert.equal(1450, a1.altitude)
      -- a2 descends (gap from a1 is 650 > 500): 2100 - 50 = 2050
      assert.equal(2050, a2.altitude)
      -- a3 held (gap from a2 is 300 < 500): stays at 2400
      assert.equal(2400, a3.altitude)
    end)
  end)
end)
