local wezterm = require 'wezterm';
local act = wezterm.action
return {
  window_decorations = "RESIZE",
  font = wezterm.font_with_fallback({
    { family = "PleckJP" },
  }),
  font_size = 16,
  color_scheme = 'Ayu Mirage',
  --color_scheme = 'GruvboxDarkHard',
  --color_scheme = 'Gruvbox dark, pale (base16)',
  hide_tab_bar_if_only_one_tab = true,
  colors = {
    foreground = 'white',
    background = 'black',
  },
  window_padding = {
    left = 4,
    right = 2,
    top = 2,
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
