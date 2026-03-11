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
  end)
end)
