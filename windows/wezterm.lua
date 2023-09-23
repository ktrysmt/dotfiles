local wezterm = require 'wezterm';
local act = wezterm.action
return {
  font = wezterm.font_with_fallback({
    { family = "Cica" },
    --{family="Cica", weight="Bold"},
  }),
  font_size = 12,
  color_scheme = 'Ayu Mirage',
  hide_tab_bar_if_only_one_tab = true,
  --line_height = 0.9,
  --cell_width = 0.9,
  colors = {
    -- The default text color
    foreground = 'white',
    -- The default background color
    background = 'black',
  },
  window_padding = {
    left = 2,
    right = 2,
    top = 0,
    bottom = 0,
  },
  underline_thickness = "1px",
  underline_position = "-2px",
  scrollback_lines = 35000,
  keys = {
    { key = 'v', mods = 'ALT',          action = act.PasteFrom 'Clipboard' },
    { key = 'v', mods = 'ALT',          action = act.PasteFrom 'PrimarySelection' },
    { key = 'f', mods = 'CTRL | SHIFT', action = act.ToggleFullScreen },
  }
}
