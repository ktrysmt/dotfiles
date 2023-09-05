return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  config = function()
    local fzf = require("fzf-lua")
    fzf.setup({
      winopts = {
        height     = 0.85,     -- window height
        width      = 0.80,     -- window width
        row        = 0.35,     -- window row position (0=top, 1=bottom)
        col        = 0.50,     -- window col position (0=left, 1=right)
        border     = 'rounded', -- 'none', 'single', 'double', 'thicc' or 'rounded'
        fullscreen = false,    -- start fullscreen?
      },
    })

    vim.cmd [[
    highlight FzfLuaNormal guibg=#383850
    highlight FzfLuaBorder guibg=#383850
    ]]

    vim.opt.winblend = 5
    vim.opt.termguicolors = true

    local opt = { silent = true }
    vim.keymap.set('n', '<leader>r', "<cmd>:FzfLua grep<CR>", opt)
    vim.keymap.set('n', '<leader>f', "<cmd>:FzfLua files<CR>", opt)
    vim.keymap.set('n', '<leader>b', "<cmd>:FzfLua buffers<CR>", opt)
    vim.keymap.set('n', '<leader>d', "<cmd>:FzfLua git_status<CR>", opt)
    vim.keymap.set('n', '<leader>ch', "<cmd>:FzfLua command_history<CR>", opt)
    vim.keymap.set('n', '<leader>sh', "<cmd>:FzfLua search_history <CR>", opt)
    vim.keymap.set('n', '<leader>m', "<cmd>:FzfLua keymaps<CR>", opt)
    vim.keymap.set('n', '<leader>x', "<cmd>:FzfLua commands<CR>", opt)

    vim.keymap.set('n', '<leader>d', "<cmd>lua require('fzf-lua').git_status()<CR>")
    vim.keymap.set('n', '<leader>b', "<cmd>lua require('fzf-lua').git_branches()<CR>")
    vim.keymap.set('n', '<leader>p', "<cmd>lua require('fzf-lua').grep()<CR>")
    vim.keymap.set('n', '<leader>/', "<cmd>lua require('fzf-lua').blines()<CR>")

    vim.keymap.set('n', '<leader>ld', "<cmd>lua require('fzf-lua').lsp_definitions()<CR>")
  end
}
