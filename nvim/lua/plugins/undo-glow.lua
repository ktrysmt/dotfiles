return {
  {
    'y3owk1n/undo-glow.nvim',
    keys = { "u", "<C-r>" },
    config = function()
      local undo_glow = require('undo-glow')
      undo_glow.setup({
        highlights = {
          undo = {
            hl_color = { bg = "#663333" }, -- Dark muted red
          },
          redo = {
            hl_color = { bg = "#2F4640" }, -- Dark muted green
          },
          yank = {
            hl_color = { bg = "#7A683A" }, -- Dark muted yellow
          },
          paste = {
            hl_color = { bg = "#325B5B" }, -- Dark muted cyan
          },
          search = {
            hl_color = { bg = "#5C475C" }, -- Dark muted purple
          },
          comment = {
            hl_color = { bg = "#7A5A3D" }, -- Dark muted orange
          },
          cursor = {
            hl_color = { bg = "#793D54" }, -- Dark muted pink
          },
        },
      })

      vim.keymap.set('n', 'u', undo_glow.undo, { desc = 'Undo with highlight' })
      vim.keymap.set('n', '<C-r>', undo_glow.redo, { desc = 'Redo with highlight' })

      -- vim.keymap.set('n', 'p', function()
      --   undo_glow.paste_below()
      --   vim.cmd.normal({ args = { '`]' }, bang = true })
      -- end, { desc = 'Paste below with highlight' })
      -- vim.keymap.set('n', 'P', function()
      --   undo_glow.paste_above()
      --   vim.cmd.normal({ args = { '`]' }, bang = true })
      -- end, { desc = 'Paste above with highlight' })
    end
  },
}
