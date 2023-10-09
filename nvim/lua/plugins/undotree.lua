return {
  'mbbill/undotree',
  event = { "CursorMoved", "InsertEnter", "CmdlineEnter", "CmdwinEnter", "ModeChanged" },
  keys = {
    { "<leader>un", mode = "n" }
  },
  dependencies = {
    'stevearc/stickybuf.nvim', -- don't override buf
  },
  config = function()
    local opt = { silent = true }
    vim.keymap.set("n", "<leader>un", "<cmd>:UndotreeToggle<cr>", opt)

    vim.cmd [[
      set undodir=$HOME/.cache/nvim/undofile
    ]]
    vim.opt.undofile                  = true
    -- vim.opt.undodir                   = vim.fn.expand("~/.cache/nvim/undofile")
    vim.g.undotree_DiffpanelHeight    = 30
    vim.g.undotree_SplitWidth         = 50
    vim.g.undotree_SetFocusWhenToggle = 1

    vim.g.undotree_CustomUndotreeCmd  = 'botright vertical 30 new'
    vim.g.undotree_CustomDiffpanelCmd = 'belowright 10 new'
  end
}
