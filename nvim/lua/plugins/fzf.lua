return {
  "ibhagwan/fzf-lua",
  keys = {
    {'<leader>r', "<cmd>:FzfLua grep<CR><CR>", silent = true },
    {'<leader>f', "<cmd>lua require('fzf-lua').files()<CR>", silent = true },
    {'<leader>b', "<cmd>:FzfLua buffers<CR>", silent = true },
    {'<leader>d', "<cmd>:FzfLua git_status<CR>", silent = true },
    {'<leader>ch', "<cmd>:FzfLua command_history<CR>", silent = true },
    {'<leader>sh', "<cmd>:FzfLua search_history <CR>", silent = true },
    {'<leader>m', "<cmd>:FzfLua keymaps<CR>", silent = true },
    {'<leader>x', "<cmd>:FzfLua commands<CR>", silent = true },
    {'<leader>ld', "<cmd>lua require('fzf-lua').lsp_definitions()<CR>", silent = true },
  },
  config = function()
    local fzf = require("fzf-lua")

    fzf.setup({
      winopts = {
        height     = 0.85,     -- window height
        width      = 0.99,     -- window width
        row        = 0.99,     -- window row position (0=top, 1=bottom)
        col        = 0.50,     -- window col position (0=left, 1=right)
        fullscreen = false,    -- start fullscreen?
        preview = {
          horizontal = 'right:40%',
        }
      },
    })

    vim.cmd [[
    highlight FzfLuaNormal guibg=#282840
    highlight FzfLuaBorder guibg=#282840
    ]]

    vim.o.winblend = 20
    vim.o.pumblend = 20

  end
}
