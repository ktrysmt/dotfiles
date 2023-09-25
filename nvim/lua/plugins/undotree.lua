return {
  'mbbill/undotree',
  event = { 'VeryLazy' },
  dependencies = {
    {
      'stevearc/stickybuf.nvim',
      config = function()
        local stickybuf_group = vim.api.nvim_create_augroup('stickybuf_group', { clear = true })
        vim.api.nvim_create_autocmd({ 'BufEnter' }, {
          pattern = "undotree",
          group = stickybuf_group,
          command = "PinFiletype",
        })
      end
    }
  },
  config = function()
    local opt = { silent = true }
    vim.keymap.set("n", "<leader>un", "<cmd>:UndotreeToggle<cr>:UndotreeFocus<cr>", opt)

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
