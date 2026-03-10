std = "lua54"

-- Playdate globals
globals = {
  "playdate",
  "import",
  "kTextAlignment",
  -- Module globals (Playdate's import doesn't return values, so modules assign to globals)
  "Strings",
  "Constants",
  "Aircraft",
  "Queue",
  "UI",
  "log",
}

-- Ignore line length (StyLua handles formatting)
ignore = { "631" }

max_cyclomatic_complexity = 10

-- busted test globals
files["spec/**/*_spec.lua"] = {
  std = "+busted",
}
