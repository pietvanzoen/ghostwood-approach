require("source.constants")
require("source.queue")
require("source.shift")

local function make_schedule()
  return {
    { time = 0, aircraft = { callsign = "A1" } },
    { time = 10, aircraft = { callsign = "A2" } },
  }
end

describe("Shift", function()
  describe("Shift.new", function()
    it("returns empty landing list", function()
      local s = Shift.new(make_schedule())
      assert.same({}, s.landing)
    end)

    it("returns empty holding list", function()
      local s = Shift.new(make_schedule())
      assert.same({}, s.holding)
    end)

    it("sets elapsed = 0", function()
      local s = Shift.new(make_schedule())
      assert.equal(0, s.elapsed)
    end)

    it("sets next_arrival = 1", function()
      local s = Shift.new(make_schedule())
      assert.equal(1, s.next_arrival)
    end)

    it("attaches the given schedule", function()
      local sched = make_schedule()
      local s = Shift.new(sched)
      assert.equal(sched, s.schedule)
    end)

    it("respects Constants.MAX_LANDING cap", function()
      local s = Shift.new(make_schedule())
      assert.equal(Constants.MAX_LANDING, s.max_landing)
    end)
  end)
end)
