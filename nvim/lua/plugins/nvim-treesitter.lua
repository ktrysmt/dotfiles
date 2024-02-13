return {
  'nvim-treesitter/nvim-treesitter',
  version = "*", -- fix to use stable
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
        "svelte",
        "astro",
        "css",
        "git_rebase",
        "gitcommit",
      },
      auto_install = true,
      highlight = {
        enable = true,
        disable = function(lang, buf)
          -- print(lang)
          if lang ~= "terraform" and lang ~= "astro" then
            -- print(lang)
            return true
          end
        end
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
    }

    -- Diagnostic keymaps
    -- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
    -- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
    -- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
    -- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
  end
}
