return {
  'mbbill/undotree',
  keys = {
    { "<leader>un", mode = "n" }
  },
  config = function()
    local opt = { silent = true }
    vim.keymap.set("n", "<leader>un", "<cmd>:UndotreeToggle<cr>:UndotreeFocus<cr>", opt)

    vim.o.undofile = true
    vim.o.undodir="~/.cache/nvim/undofile"
    vim.g.undotree_WindowLayout = 3
    vim.g.undotree_DiffpanelHeight = 30
    vim.g.undotree_SplitWidth = 50

  end
}
