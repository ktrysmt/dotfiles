return {
  'stevearc/stickybuf.nvim',
  keys = {
    { "<C-e>",      mode = 'n' }, -- for fern
    { "<leader>un", mode = "n" }, -- for undotree
    { "<leader>t",  mode = "n" }, -- for terminal
    { "<leader>vt", mode = "n" }, -- for terminal
    { "<leader>T",  mode = "n" }, -- for terminal
  },
  event = { "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  config = function()
    require("stickybuf").setup()

    local stickybuf_group = vim.api.nvim_create_augroup('stickybuf_group', { clear = true })
    -- undotree
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "undotree",
      group = stickybuf_group,
      command = "PinBuftype | PinBuftype",
    })
    -- terminal
    vim.api.nvim_create_autocmd("BufNew", {
      pattern = "term://*",
      group = stickybuf_group,
      command = "PinBuffer!"
    })
  end
}
