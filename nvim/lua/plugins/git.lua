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
      require('gitsigns').setup({
        signs         = {
          add          = { text = '+' },
          change       = { text = '|' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        sign_priority = 2,
        signcolumn    = true,
        numhl         = false,
        linehl        = false,
      })

      vim.cmd [[
      highlight GitSignsAdd guifg=#528832
      ]]
    end
  },
}
