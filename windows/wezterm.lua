local wezterm = require 'wezterm';
local act = wezterm.action
return {
  font = wezterm.font_with_fallback({
    { family = "Cica" },
  }),
  font_size = 12,
  color_scheme = 'Ayu Mirage',
  hide_tab_bar_if_only_one_tab = true,
  colors = {
    foreground = 'white',
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
    { key = 'f', mods = 'CTRL | SHIFT', action = act.ToggleFullScreen },
  }
}
