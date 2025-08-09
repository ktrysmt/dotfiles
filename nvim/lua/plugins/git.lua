return {
  {
    -- how to fix conflict
    -- 1. open the conflicted file or :G and select it
    -- 2. :Git mergetool
    -- 3. :GitConflictChooseBoth or ...
    -- 4. save and commit it
    "akinsho/git-conflict.nvim",
    event = { "CursorHold", "CursorMoved", "ModeChanged", "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
    -- event = { "VeryLazy" },
    version = "*",
    config = function()
      require('git-conflict').setup()
      local gitconflict_group = vim.api.nvim_create_augroup('gitconflict_group', { clear = true })
      vim.api.nvim_create_autocmd('User', {
        pattern = 'GitConflictDetected',
        group = gitconflict_group,
        callback = function()
          vim.notify('Conflict detected in ' .. vim.fn.expand('<afile>'))
          vim.keymap.set('n', 'cww', function()
            engage.conflict_buster()
            create_buffer_local_mappings()
          end)
        end
      })
    end
  },
  {
    'tpope/vim-fugitive',
    event = { "CmdlineEnter", "CmdwinEnter" },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { "CursorHold", "CursorMoved", "ModeChanged", "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
    config = function()
      local gitsigns = require('gitsigns')
      gitsigns.setup({
        signs         = {
          add          = { text = '+' },
          change       = { text = '=' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged  = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '┃' },
          topdelete    = { text = '┃' },
          changedelete = { text = '┃' },
          untracked    = { text = '┆' },
        },
        sign_priority = 2,
        signcolumn    = true,
        numhl         = false,
        linehl        = false,
      })

      local opt = { silent = true }
      vim.keymap.set("n", "gw", function()
        gitsigns.nav_hunk('next', { target = 'all' })
      end, opt)
      vim.keymap.set("n", "gb", function()
        gitsigns.nav_hunk('prev', { target = 'all' })
      end, opt)
      vim.keymap.set({ "n", "v" }, "g+", function()
        gitsigns.stage_hunk()
      end, opt)
      vim.keymap.set({ "n", "v" }, "g-", function()
        gitsigns.undo_stage_hunk()
      end, opt)
    end
  },
}
