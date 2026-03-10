-- Game-wide constants.
-- Centralises magic numbers for screen layout and game parameters.

-- luacheck: globals Constants
Constants = {
  -- Playdate display is always 400x240
  SCREEN_WIDTH = 400,
  SCREEN_HEIGHT = 240,
  SCREEN_CENTER_X = 200,
  SCREEN_CENTER_Y = 120,

  -- Title screen layout
  TITLE_HEADING_Y = 100,
  TITLE_PROMPT_Y = 140,

  -- Aircraft card layout (flight progress strip style).
  -- Strip is horizontally divided into four columns by vertical dividers.
  -- Each column shows a value on top and a small label below.
  CARD = {
    X = 10,
    Y = 91, -- vertically centred reference; shift screen uses CARD_LIST_START_Y instead
    WIDTH = 380,
    HEIGHT = 44, -- compact height to allow stacked cards
    TAB_WIDTH = 6, -- solid left-edge tab, like a physical strip holder
    CARD_GAP = 3, -- vertical gap between stacked cards

    -- Absolute x positions of the three column dividers
    DIV1_X = 150, -- right edge of callsign column
    DIV2_X = 210, -- right edge of altitude column
    DIV3_X = 270, -- right edge of fuel column

    -- Y offsets from the strip top for the two text rows in each column
    VALUE_Y_OFFSET = 6,
    LABEL_Y_OFFSET = 26,
  },

  -- Single-column shift screen layout
  SECTION_HEADER_HEIGHT = 14,
  CARD_LIST_START_Y = 4,
  MAX_LANDING = 3,
}
