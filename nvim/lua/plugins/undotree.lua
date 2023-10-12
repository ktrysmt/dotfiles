return {
  'mbbill/undotree', --and terminal
  event = { "CursorHold", "CursorMoved", "ModeChanged", "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  keys = {
    { "<leader>un", "<cmd>:UndotreeToggle<cr>", mode = "n", silent = true }, -- for undotree
  },
  dependencies = {
    'stevearc/stickybuf.nvim',
  },
  config = function()
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

    require("stickybuf").setup()
    local undotree_group = vim.api.nvim_create_augroup('undotree_group', { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "undotree",
      group = undotree_group,
      command = "PinBuftype | PinBuftype",
    })
  end
}
