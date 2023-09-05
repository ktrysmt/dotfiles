return {
  "gbprod/substitute.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local opt = { silent = true }
    vim.keymap.set("n", "s", "<cmd>lua require('substitute').operator()<cr>", opt)
    vim.keymap.set("n", "ss", "<cmd>lua require('substitute').line()<cr>", opt)
    vim.keymap.set("n", "S", "<cmd>lua require('substitute').eol()<cr>", opt)
    vim.keymap.set("x", "s", "<cmd>lua require('substitute').visual()<cr>", opt)
  end
}
