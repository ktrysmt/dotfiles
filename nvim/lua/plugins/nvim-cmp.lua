return {
  'hrsh7th/nvim-cmp',
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",
    "hrsh7th/vim-vsnip-integ",
    "rafamadriz/friendly-snippets",
    'andersevenrud/cmp-tmux',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-calc',
    "ray-x/cmp-treesitter",
    -- {
    --   'tzachar/cmp-tabnine',
    --   build = './install.sh',
    -- },
  },
  config = function()
    vim.keymap.set({ 'i', 's' }, '<C-j>', function()
      return vim.fn['vsnip#jumpable'](1) == 1 and '<Plug>(vsnip-jump-next)'
    end, { expr = true })
    vim.keymap.set({ 'i', 's' }, '<C-k>', function()
      return vim.fn['vsnip#jumpable'](-1) == 1 and '<Plug>(vsnip-jump-prev)'
    end, { expr = true })

    vim.g.vsnip_filetypes = {
      javascriptreact = { "javascript" },
      typescriptreact = { "typescript" },
      ["typescript.tsx"] = { "typescript" },
    }

    local cmp = require('cmp')

    cmp.setup({
      enabled = true,

      completion = {
        completeopt = 'menu,menuone,noinsert'
      },

      preselect = require('cmp').PreselectMode.None,

      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        end,
      },

      mapping = cmp.mapping.preset.insert({
        ['<Up>'] = cmp.mapping.scroll_docs(-4),
        ['<Down>'] = cmp.mapping.scroll_docs(4),
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        },
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_next_item()
          else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Down>', true, true, true), 'i', true)
          end
        end, { "i" }),
        ["<C-p>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item()
          else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Up>', true, true, true), 'i', true)
          end
        end, { "i" }),
      }),

      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        {
          name = 'buffer',
          option = {
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end
          }
        },
        { name = 'path' },
        { name = 'tmux' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'calc' },
        { name = 'treesitter' },
        -- { name = 'cmp_tabnine' },
      }),

      experimental = {
        ghost_text = true,
      },
    })

    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
          { name = 'path' }
        },
        {
          {
            name = 'cmdline',
            option = {
              ignore_cmds = { 'Man', '!' }
            }
          }
        })
    })
  end
}
