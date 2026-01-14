return {
  {
    'y3owk1n/undo-glow.nvim',
    event = { "VeryLazy" },
    config = function()
      local undo_glow = require('undo-glow')
      undo_glow.setup()

      vim.keymap.set('n', 'u', undo_glow.undo, { desc = 'Undo with highlight' })
      vim.keymap.set('n', 'U', undo_glow.redo, { desc = 'Redo with highlight' })

      vim.keymap.set('n', 'p', function()
        undo_glow.paste_below()
        vim.cmd.normal({ args = { '`]' }, bang = true })
      end, { desc = 'Paste below with highlight' })
      vim.keymap.set('n', 'P', function()
        undo_glow.paste_above()
        vim.cmd.normal({ args = { '`]' }, bang = true })
      end, { desc = 'Paste above with highlight' })
    end
  },
}
