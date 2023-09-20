return {
  'mbbill/undotree',
  keys = {
    { "<leader>un", mode = "n" }
  },
  config = function()
    local opt = { silent = true }
    vim.keymap.set("n", "<leader>un", "<cmd>:UndotreeToggle<cr>:UndotreeFocus<cr>", opt)

    vim.o.undofile                    = true
    vim.o.undodir                     = "~/.cache/nvim/undofile"
    vim.g.undotree_DiffpanelHeight    = 30
    vim.g.undotree_SplitWidth         = 50
    vim.g.undotree_SetFocusWhenToggle = 1

    vim.g.undotree_CustomUndotreeCmd  = 'botright vertical 30 new'
    vim.g.undotree_CustomDiffpanelCmd = 'belowright 10 new'
  end
}
