return {
  'nvim-treesitter/nvim-treesitter',
  -- version = "*", -- fix to use stable
  event = { "BufReadPre", "BufNewFile" },
  -- event = "VeryLazy",
  -- event = { "CursorHold", "CursorMoved" },
  build = ':TSUpdate',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
    'nvim-treesitter/nvim-treesitter-textobjects',
    'RRethy/nvim-treesitter-textsubjects',
    'andymass/vim-matchup',
  },
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        "astro",
        "css",
        "git_rebase",
        "gitcommit",
        "gitignore",
        "hcl",
        "json",
        "json5",
        "jsonc",
        "markdown",
        "markdown_inline",
        "svelte",
        "terraform",
        'dockerfile',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'kotlin',
        'lua',
        'python',
        'rust',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = {
        enable = true,
        disable = { "astro", "yaml", "yaml.ansible" },
      },
      indent = { enable = false },
      incremental_selection = { -- or, you should use "vib" and dot repeat...
        enable = false,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- ["af"] = "@function.outer",
            -- ["if"] = "@function.inner",
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
          -- ['.'] = 'textsubjects-container-inner',
        },
      },
      matchup = {
        enable = true,             -- mandatory, false will disable the whole extension
        disable = { "c", "ruby" }, -- optional, list of language that will be disabled
        -- [options]
      },
    }

    -- Diagnostic keymaps
    -- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
    -- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
    -- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
    -- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
  end
}
