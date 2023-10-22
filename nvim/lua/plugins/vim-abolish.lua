return {
  'tpope/vim-abolish',
  event = { 'CmdlineEnter', 'CmdwinEnter' }, -- :Subvert
  keys = {
    { "crs", mode = "n" },                   -- to snake_case
    { "crc", mode = "n" },                   -- to camelCase
    { "crk", mode = "n" },                   -- to kebab-case
    { "cru", mode = "n" },                   -- to UPPER_CASE
    { "crm", mode = "n" },                   -- to MixedCase
  }
}
