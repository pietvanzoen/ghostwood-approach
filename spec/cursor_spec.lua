require("source.constants")
require("source.cursor")

-- Helper: builds a minimal queue state with landing and holding lists.
local function make_state(landing, holding)
  return { landing = landing or {}, holding = holding or {} }
end

-- Helper: builds a dummy aircraft placeholder (cursor tests don't need real aircraft).
local function dummy()
  return {}
end

describe("Cursor", function()
  -- ─── Cursor.up ───────────────────────────────────────────────────────────────

  describe("Cursor.up", function()
    it("decrements index when above position 1 in the same section", function()
      local cursor = { section = Constants.SECTION_LANDING, index = 3 }
      local state = make_state({ dummy(), dummy(), dummy() })
      Cursor.up(cursor, state)
      assert.equal(2, cursor.index)
      assert.equal(Constants.SECTION_LANDING, cursor.section)
    end)

    it("crosses from holding into landing when at holding index 1 and landing is non-empty", function()
      local state = make_state({ dummy(), dummy() }, { dummy() })
      local cursor = { section = Constants.SECTION_HOLDING, index = 1 }
      Cursor.up(cursor, state)
      assert.equal(Constants.SECTION_LANDING, cursor.section)
      assert.equal(2, cursor.index) -- last landing aircraft
    end)

    it("focuses the last landing aircraft when crossing from holding", function()
      local state = make_state({ dummy(), dummy(), dummy() }, { dummy() })
      local cursor = { section = Constants.SECTION_HOLDING, index = 1 }
      Cursor.up(cursor, state)
      assert.equal(3, cursor.index)
    end)

    it("stays in place at landing index 1 (no section above landing)", function()
      local state = make_state({ dummy(), dummy() })
      local cursor = { section = Constants.SECTION_LANDING, index = 1 }
      Cursor.up(cursor, state)
      assert.equal(Constants.SECTION_LANDING, cursor.section)
      assert.equal(1, cursor.index)
    end)

    it("stays in place at holding index 1 when landing is empty", function()
      local state = make_state({}, { dummy(), dummy() })
      local cursor = { section = Constants.SECTION_HOLDING, index = 1 }
      Cursor.up(cursor, state)
      assert.equal(Constants.SECTION_HOLDING, cursor.section)
      assert.equal(1, cursor.index)
    end)
  end)

  -- ─── Cursor.down ─────────────────────────────────────────────────────────────

  describe("Cursor.down", function()
    it("increments index when below the last position in the same section", function()
      local cursor = { section = Constants.SECTION_LANDING, index = 1 }
      local state = make_state({ dummy(), dummy(), dummy() })
      Cursor.down(cursor, state)
      assert.equal(2, cursor.index)
      assert.equal(Constants.SECTION_LANDING, cursor.section)
    end)

    it("crosses from landing into holding when at the last landing position and holding is non-empty", function()
      local state = make_state({ dummy() }, { dummy(), dummy() })
      local cursor = { section = Constants.SECTION_LANDING, index = 1 }
      Cursor.down(cursor, state)
      assert.equal(Constants.SECTION_HOLDING, cursor.section)
      assert.equal(1, cursor.index)
    end)

    it("stays in place at the last holding position (no section below)", function()
      local state = make_state({}, { dummy(), dummy() })
      local cursor = { section = Constants.SECTION_HOLDING, index = 2 }
      Cursor.down(cursor, state)
      assert.equal(Constants.SECTION_HOLDING, cursor.section)
      assert.equal(2, cursor.index)
    end)

    it("stays in place at the last landing position when holding is empty", function()
      local state = make_state({ dummy(), dummy() }, {})
      local cursor = { section = Constants.SECTION_LANDING, index = 2 }
      Cursor.down(cursor, state)
      assert.equal(Constants.SECTION_LANDING, cursor.section)
      assert.equal(2, cursor.index)
    end)
  end)

  -- ─── Cursor.clamp_after_land ──────────────────────────────────────────────────

  describe("Cursor.clamp_after_land", function()
    it("shifts to holding[1] when landing empties and holding has aircraft", function()
      local state = make_state({}, { dummy() })
      local cursor = { section = Constants.SECTION_LANDING, index = 1 }
      Cursor.clamp_after_land(cursor, state)
      assert.equal(Constants.SECTION_HOLDING, cursor.section)
      assert.equal(1, cursor.index)
    end)

    it("parks cursor at index 1 when both lists are empty", function()
      local state = make_state({}, {})
      local cursor = { section = Constants.SECTION_LANDING, index = 1 }
      Cursor.clamp_after_land(cursor, state)
      assert.equal(Constants.SECTION_LANDING, cursor.section)
      assert.equal(1, cursor.index)
    end)

    it("clamps index to new landing length when landing still has aircraft", function()
      local state = make_state({ dummy(), dummy() })
      local cursor = { section = Constants.SECTION_LANDING, index = 3 }
      Cursor.clamp_after_land(cursor, state)
      assert.equal(Constants.SECTION_LANDING, cursor.section)
      assert.equal(2, cursor.index)
    end)

    it("does not move cursor index when it is already within the new landing length", function()
      local state = make_state({ dummy(), dummy() })
      local cursor = { section = Constants.SECTION_LANDING, index = 1 }
      Cursor.clamp_after_land(cursor, state)
      assert.equal(1, cursor.index)
    end)

    it("does nothing when cursor is in holding", function()
      local state = make_state({}, { dummy() })
      local cursor = { section = Constants.SECTION_HOLDING, index = 1 }
      Cursor.clamp_after_land(cursor, state)
      assert.equal(Constants.SECTION_HOLDING, cursor.section)
      assert.equal(1, cursor.index)
    end)
  end)

  -- ─── Cursor.clamp_after_promote ───────────────────────────────────────────────

  describe("Cursor.clamp_after_promote", function()
    it("shifts to the promoted aircraft in landing when holding empties", function()
      -- After promote: holding is empty, landing now has 1 aircraft.
      local state = make_state({ dummy() }, {})
      local cursor = { section = Constants.SECTION_HOLDING, index = 1 }
      Cursor.clamp_after_promote(cursor, state)
      assert.equal(Constants.SECTION_LANDING, cursor.section)
      assert.equal(1, cursor.index) -- #state.landing = 1
    end)

    it("focuses the last landing aircraft when holding empties and landing has multiple", function()
      local state = make_state({ dummy(), dummy(), dummy() }, {})
      local cursor = { section = Constants.SECTION_HOLDING, index = 1 }
      Cursor.clamp_after_promote(cursor, state)
      assert.equal(3, cursor.index)
    end)

    it("clamps holding index when cursor exceeds the new holding length", function()
      -- Promoted index 3 from a 3-item list; holding now has 2.
      local state = make_state({ dummy() }, { dummy(), dummy() })
      local cursor = { section = Constants.SECTION_HOLDING, index = 3 }
      Cursor.clamp_after_promote(cursor, state)
      assert.equal(Constants.SECTION_HOLDING, cursor.section)
      assert.equal(2, cursor.index)
    end)

    it("does not change index when it is still within the new holding length", function()
      local state = make_state({ dummy() }, { dummy(), dummy() })
      local cursor = { section = Constants.SECTION_HOLDING, index = 1 }
      Cursor.clamp_after_promote(cursor, state)
      assert.equal(Constants.SECTION_HOLDING, cursor.section)
      assert.equal(1, cursor.index)
    end)

    it("does nothing when cursor is in landing", function()
      local state = make_state({ dummy() }, { dummy() })
      local cursor = { section = Constants.SECTION_LANDING, index = 1 }
      Cursor.clamp_after_promote(cursor, state)
      assert.equal(Constants.SECTION_LANDING, cursor.section)
      assert.equal(1, cursor.index)
    end)
  end)
end)
