return {
  'hrsh7th/nvim-cmp',
  event = "InsertEnter",
  dependencies = {
    'L3MON4D3/LuaSnip',
    -- 'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-nvim-lsp',
    'rafamadriz/friendly-snippets',
    -- 'onsails/lspkind.nvim',
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",
    "hrsh7th/vim-vsnip-integ",
    "rafamadriz/friendly-snippets",
  },
  config = function()

    local cmp = require('cmp')

    -- local luasnip = require 'luasnip'
    -- vim.keymap.set({"i", "s"}, "<C-j>", function() luasnip.jump( 1) end, {silent = true})
    -- vim.keymap.set({"i", "s"}, "<C-k>", function() luasnip.jump(-1) end, {silent = true})
    -- local lspkind = require('lspkind')
    -- require('luasnip.loaders.from_vscode').lazy_load()
    -- luasnip.config.setup {}

    -- wip
    --
    -- vim.keymap.set({'i', 's'}, '<C-l>', function() return vim.fn['vsnip#available'](1) == 1 and '<Plug>(vsnip-expand-or-jump)' or '<C-l>' end, { expr = true, noremap = false })
    -- vim.keymap.set({'i', 's'}, '<Tab>', function() return vim.fn['vsnip#jumpable'](1) == 1 and '<Plug>(vsnip-jump-next)' or '<Tab>' end, { expr = true, noremap = false })
    -- vim.keymap.set({'i', 's'}, '<S-Tab>', function() return vim.fn['vsnip#jumpable'](-1) == 1 and '<Plug>(vsnip-jump-prev)' or '<S-Tab>' end, { expr = true, noremap = false })
    -- vim.keymap.set({"i", "s"}, "<C-e>", function() luasnip.jump( 1) end, {silent = true})
    -- vim.keymap.set({"i", "s"}, "<C-k>", function() luasnip.jump(-1) end, {silent = true})

    --" Expand
    vim.keymap.set({'i', 's'}, '<C-e>', function() return vim.fn['vsnip#expandable']() == 1 and '<Plug>(vsnip-expand)' end, { expr = true })
    vim.keymap.set({'i', 's'}, '<C-j>', function() return vim.fn['vsnip#jumpable'](1) == 1 and '<Plug>(vsnip-jump-next)' end, { expr = true })
    vim.keymap.set({'i', 's'}, '<C-k>', function() return vim.fn['vsnip#jumpable'](-1) == 1 and '<Plug>(vsnip-jump-prev)' end, { expr = true })
    vim.g.vsnip_filetypes = {
      javascriptreact = { "javascript" },
      typescriptreact = { "typescript" },
      ["typescript.tsx"] = { "typescript" },
    }


    cmp.setup({
      enabled = true,
      completion = {
        completeopt = 'menuone,noselect,noinsert',
      },

      snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
          -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
      },

      mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        -- ['<C-space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Insert,
          select = false,
        },
      }),

      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'buffer' },
        { name = 'path' },
      }),

      -- formatting = {
      --   fields = { 'abbr', 'kind', 'menu' },
      --   format = lspkind.cmp_format({
      --     mode = 'symbol_text',
      --     maxwidth = 50,
      --     ellipsis_char = '...',
      --     menu = ({
      --       buffer = "[Buffer]",
      --       nvim_lsp = "[LSP]",
      --       luasnip = "[LuaSnip]",
      --     }),
      --
      --     symbol_map = {
      --       Constructor = "",
      --       Field = "ﰠ",
      --       Variable = "",
      --       Class = "ﴯ",
      --       Interface = "",
      --       Module = "",
      --       Property = "ﰠ",
      --       Unit = "塞",
      --       Value = "",
      --       Enum = "",
      --       Keyword = "",
      --       Snippet = "",
      --       EnumMember = "",
      --       Struct = "פּ",
      --       Event = "",
      --       TypeParameter = "",
      --     }
      --   }),
      -- },

      experimental = {
        ghost_text = true,
      },
    })
  end
}
