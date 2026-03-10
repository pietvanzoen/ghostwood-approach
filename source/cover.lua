-- Stillwater Approach
-- Cover art: tower-centric scene with fog, runway, and approaching aircraft
-- luacheck: globals Cover

local gfx <const> = playdate.graphics

Cover = {}

-- Draw organic fog/clouds using wavy lines
local function draw_fog()
  gfx.setColor(gfx.kColorBlack)
  gfx.setLineWidth(1)

  -- Three layers of fog drift
  local offsets = { 10, 20, 30 }
  for _, offset in ipairs(offsets) do
    local y = 20 + offset
    gfx.drawLine(0, y, 80, y - 3)
    gfx.drawLine(80, y - 3, 160, y + 2)
    gfx.drawLine(160, y + 2, 240, y - 4)
    gfx.drawLine(240, y - 4, 320, y + 1)
    gfx.drawLine(320, y + 1, 400, y - 2)
  end
end

-- Draw forested ridgelines (jagged triangular shapes at bottom)
local function draw_ridgelines()
  gfx.setColor(gfx.kColorBlack)
  gfx.setLineWidth(1)

  -- Left ridge
  local left_ridge = {
    { 0, 240 },
    { 40, 180 },
    { 80, 200 },
    { 120, 160 },
    { 160, 190 },
    { 200, 170 }
  }
  for i = 1, #left_ridge - 1 do
    local p1 = left_ridge[i]
    local p2 = left_ridge[i + 1]
    gfx.drawLine(p1[1], p1[2], p2[1], p2[2])
  end

  -- Right ridge
  local right_ridge = {
    { 200, 170 },
    { 240, 150 },
    { 280, 175 },
    { 320, 155 },
    { 360, 185 },
    { 400, 165 },
    { 400, 240 }
  }
  for i = 1, #right_ridge - 1 do
    local p1 = right_ridge[i]
    local p2 = right_ridge[i + 1]
    gfx.drawLine(p1[1], p1[2], p2[1], p2[2])
  end

  -- Fill ridges with hatching (dense crosshatch for "forested" look)
  gfx.setLineWidth(1)
  for x = 0, 400, 3 do
    gfx.drawLine(x, 200, x + 40, 240)
  end
  for x = 400, 0, -3 do
    gfx.drawLine(x, 200, x - 40, 240)
  end
end

-- Draw the control tower: vertical structure with beacon light
local function draw_tower()
  gfx.setColor(gfx.kColorBlack)
  gfx.setLineWidth(2)

  local tower_x = 200
  local tower_base_y = 140
  local tower_height = 50

  -- Tower shaft
  gfx.drawLine(tower_x - 4, tower_base_y, tower_x - 4, tower_base_y - tower_height)
  gfx.drawLine(tower_x + 4, tower_base_y, tower_x + 4, tower_base_y - tower_height)

  -- Tower cabin (small rectangle at top)
  gfx.drawRect(tower_x - 8, tower_base_y - tower_height - 8, 16, 8)

  -- Beacon light (circle at very top)
  gfx.setLineWidth(1)
  gfx.drawCircleAtPoint(tower_x, tower_base_y - tower_height - 12, 3)

  -- Tower legs/base
  gfx.setLineWidth(1)
  gfx.drawLine(tower_x - 12, tower_base_y, tower_x - 4, tower_base_y)
  gfx.drawLine(tower_x + 4, tower_base_y, tower_x + 12, tower_base_y)
  gfx.drawLine(tower_x - 12, tower_base_y, tower_x - 10, tower_base_y + 6)
  gfx.drawLine(tower_x + 12, tower_base_y, tower_x + 10, tower_base_y + 6)
end

-- Draw runway (horizontal line with center markings)
local function draw_runway()
  gfx.setColor(gfx.kColorBlack)
  gfx.setLineWidth(2)

  local runway_y = 150
  gfx.drawLine(80, runway_y, 320, runway_y)

  -- Center line dashes
  gfx.setLineWidth(1)
  for x = 100, 300, 15 do
    gfx.drawLine(x, runway_y, x + 8, runway_y)
  end
end

-- Draw approaching aircraft (small side profile)
local function draw_aircraft()
  gfx.setColor(gfx.kColorBlack)
  gfx.setLineWidth(1)

  local aircraft_x = 320
  local aircraft_y = 70

  -- Fuselage
  gfx.drawLine(aircraft_x - 8, aircraft_y, aircraft_x + 8, aircraft_y)

  -- Wings
  gfx.drawLine(aircraft_x - 8, aircraft_y, aircraft_x - 12, aircraft_y - 2)
  gfx.drawLine(aircraft_x + 8, aircraft_y, aircraft_x + 12, aircraft_y - 2)

  -- Tail
  gfx.drawLine(aircraft_x + 8, aircraft_y, aircraft_x + 10, aircraft_y + 3)
  gfx.drawLine(aircraft_x + 10, aircraft_y + 3, aircraft_x + 12, aircraft_y + 1)

  -- Cockpit
  gfx.drawCircleAtPoint(aircraft_x - 3, aircraft_y - 1, 1)
end

-- Draw the complete cover
function Cover.draw()
  gfx.clear(gfx.kColorWhite)

  draw_fog()
  draw_ridgelines()
  draw_runway()
  draw_tower()
  draw_aircraft()

  -- Title text at bottom with white background for readability
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(60, 210, 280, 24)
  gfx.setColor(gfx.kColorBlack)
  gfx.setLineWidth(1)
  gfx.drawRect(60, 210, 280, 24)
  gfx.drawTextAligned(
    "STILLWATER APPROACH",
    200,
    215,
    kTextAlignment.center
  )
end

return Cover
