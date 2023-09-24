return {
  'nvim-treesitter/nvim-treesitter',
  event = "VeryLazy",
  build = ':TSUpdate',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
    'nvim-treesitter/nvim-treesitter-textobjects',
    'RRethy/nvim-treesitter-textsubjects',
  },
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        'go',
        'gosum',
        'gomod',
        'gowork',
        'lua',
        'python',
        'rust',
        'typescript',
        'tsx',
        'vimdoc',
        'vim',
        'kotlin',
        'dockerfile',
        "json",
        "json5",
        "jsonc",
        "terraform",
        "hcl",
        "markdown",
      },
      auto_install = true,
      highlight = { enable = false },
      indent = { enable = true },
      -- incemental_selection = {
      --   enable = true,
      --   keymaps = {
      --     init_selection = '<c-space>',
      --     node_incremental = '<c-space>',
      --     scope_incremental = '<c-s>',
      --     node_decremental = '<M-space>',
      --   },
      -- },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<Tab>",
          node_incremental = "<Tab>",
          scope_incremental = "<M-Tab>",
          node_decremental = "<S-Tab>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
            -- ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
          },
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V',  -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },
          include_surrounding_whitespace = false,
        },
      },
      textsubjects = {
        enable = true,
        prev_selection = ',', -- (Optional) keymap to select the previous selection
        keymaps = {
          ['.'] = 'textsubjects-smart',
          -- [';'] = 'textsubjects-container-outer',
          -- ['i;'] = 'textsubjects-container-inner',
        },
      },
    }

    -- Diagnostic keymaps
    -- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
    -- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
    -- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
    -- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
  end
}
