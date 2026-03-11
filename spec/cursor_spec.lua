require("source.constants")
require("source.cursor")

-- Helper: builds a minimal shift_state with given landing/holding counts.
local function make_state(landing_count, holding_count)
  local state = { landing = {}, holding = {} }
  for i = 1, landing_count do
    state.landing[i] = { callsign = "L" .. i }
  end
  for i = 1, holding_count do
    state.holding[i] = { callsign = "H" .. i }
  end
  return state
end

describe("Cursor", function()
  describe("Cursor.new", function()
    it("returns section = SECTION_HOLDING", function()
      local c = Cursor.new()
      assert.equal(Constants.SECTION_HOLDING, c.section)
    end)

    it("returns index = 1", function()
      local c = Cursor.new()
      assert.equal(1, c.index)
    end)
  end)

  describe("Cursor.up", function()
    it("decrements index within section", function()
      local c = { section = Constants.SECTION_HOLDING, index = 2 }
      local state = make_state(0, 3)
      Cursor.up(c, state)
      assert.equal(1, c.index)
    end)

    it("crosses into landing when at holding[1] with non-empty landing", function()
      local c = { section = Constants.SECTION_HOLDING, index = 1 }
      local state = make_state(2, 2)
      Cursor.up(c, state)
      assert.equal(Constants.SECTION_LANDING, c.section)
      assert.equal(2, c.index)
    end)

    it("no-op at holding[1] with empty landing", function()
      local c = { section = Constants.SECTION_HOLDING, index = 1 }
      local state = make_state(0, 2)
      Cursor.up(c, state)
      assert.equal(Constants.SECTION_HOLDING, c.section)
      assert.equal(1, c.index)
    end)

    it("no-op at landing[1]", function()
      local c = { section = Constants.SECTION_LANDING, index = 1 }
      local state = make_state(2, 1)
      Cursor.up(c, state)
      assert.equal(Constants.SECTION_LANDING, c.section)
      assert.equal(1, c.index)
    end)
  end)

  describe("Cursor.down", function()
    it("increments index within section", function()
      local c = { section = Constants.SECTION_LANDING, index = 1 }
      local state = make_state(3, 0)
      Cursor.down(c, state)
      assert.equal(2, c.index)
    end)

    it("crosses into holding when at bottom of landing with non-empty holding", function()
      local c = { section = Constants.SECTION_LANDING, index = 2 }
      local state = make_state(2, 2)
      Cursor.down(c, state)
      assert.equal(Constants.SECTION_HOLDING, c.section)
      assert.equal(1, c.index)
    end)

    it("no-op at bottom of landing with empty holding", function()
      local c = { section = Constants.SECTION_LANDING, index = 2 }
      local state = make_state(2, 0)
      Cursor.down(c, state)
      assert.equal(Constants.SECTION_LANDING, c.section)
      assert.equal(2, c.index)
    end)

    it("no-op at bottom of holding", function()
      local c = { section = Constants.SECTION_HOLDING, index = 2 }
      local state = make_state(0, 2)
      Cursor.down(c, state)
      assert.equal(Constants.SECTION_HOLDING, c.section)
      assert.equal(2, c.index)
    end)
  end)

  describe("Cursor.after_promote", function()
    it("moves to landing when holding empties", function()
      local c = { section = Constants.SECTION_HOLDING, index = 1 }
      local state = make_state(2, 0) -- holding now empty after promote
      Cursor.after_promote(c, state)
      assert.equal(Constants.SECTION_LANDING, c.section)
      assert.equal(2, c.index)
    end)

    it("clamps index when holding shrinks", function()
      local c = { section = Constants.SECTION_HOLDING, index = 3 }
      local state = make_state(1, 2) -- holding shrunk to 2
      Cursor.after_promote(c, state)
      assert.equal(Constants.SECTION_HOLDING, c.section)
      assert.equal(2, c.index)
    end)

    it("leaves index unchanged when still valid", function()
      local c = { section = Constants.SECTION_HOLDING, index = 1 }
      local state = make_state(1, 3)
      Cursor.after_promote(c, state)
      assert.equal(Constants.SECTION_HOLDING, c.section)
      assert.equal(1, c.index)
    end)
  end)
end)
