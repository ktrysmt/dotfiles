return {
  'nvim-treesitter/nvim-treesitter',
  event = "VeryLazy",
  build = ':TSUpdate',
  dependencies = {
    "yioneko/nvim-yati",
  },
  config = function()
    -- require("nvim-treesitter.configs").setup({
    -- auto_install = true,
    -- highlight = {
    -- enable = true,
    -- -- disable = {"markdown"},
    -- },
    -- })

    -- [[ Configure Treesitter ]]
    -- See `:help nvim-treesitter`
    require('nvim-treesitter.configs').setup {
      -- Add languages to be installed here that you want installed for treesitter
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

      -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
      auto_install = true,

      highlight = { enable = false },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<M-space>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
        -- swap = {
        --   enable = true,
        --   swap_next = {
        --     ['<leader>a'] = '@parameter.inner',
        --   },
        --   swap_previous = {
        --     ['<leader>A'] = '@parameter.inner',
        --   },
        -- },
      },
      yati = {
        enable = true,
        -- Disable by languages, see `Supported languages`
        -- disable = { "python" },

        -- Whether to enable lazy mode (recommend to enable this if bad indent happens frequently)
        default_lazy = true,

        -- Determine the fallback method used when we cannot calculate indent by tree-sitter
        --   "auto": fallback to vim auto indent
        --   "asis": use current indent as-is
        --   "cindent": see `:h cindent()`
        -- Or a custom function return the final indent result.
        default_fallback = "auto"
      },
    }

    -- Diagnostic keymaps
    -- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
    -- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
    -- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
    -- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
  end
}
