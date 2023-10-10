return {
  'stevearc/stickybuf.nvim',
  keys = {
    { "<leader>t",  [[<cmd>new | :terminal<CR><insert>]],    mode = "n", silent = true },
    { "<leader>vt", [[<cmd>vne | :terminal<CR><insert>]],    mode = "n", silent = true },
    { "<leader>T",  [[<cmd>tabnew | :terminal<CR><insert>]], mode = "n", silent = true },
  },
  config = function()
    require("stickybuf").setup()

    local stickybuf_group = vim.api.nvim_create_augroup('stickybuf_group', { clear = true })
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      group = stickybuf_group,
      command = "PinBuffer!"
    })
  end
}
