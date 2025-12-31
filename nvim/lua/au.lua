local general_group = vim.api.nvim_create_augroup('general_group', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = "*",
  group = general_group,
  command = [[%s/\s\+$//ge]],
})
vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
  pattern = "*",
  group = general_group,
  command = "set nopaste"
})
vim.api.nvim_create_autocmd({ 'QuickFixCmdPost' }, {
  pattern = "*grep*",
  group = general_group,
  command = "cwindow"
})
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  pattern = "term://*",
  group = general_group,
  command = "startinsert"
})
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { "*.yaml.j2", "*.yml.j2" },
  group = general_group,
  command = "setfiletype yaml.ansible"
})
vim.api.nvim_create_autocmd({ 'TermOpen' }, {
  pattern = "*",
  group = general_group,
  command = "setl winhighlight=Normal:User1 | setl norelativenumber | setl nonumber"
})
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  -- auto reload re-enter the buffer
  pattern = "*",
  group = general_group,
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end
})

local json_group = vim.api.nvim_create_augroup('json_group', { clear = true })
vim.api.nvim_create_autocmd({ 'Filetype' }, {
  pattern = "json",
  group = json_group,
  command = "setl conceallevel=0"
})

local highlight_group = vim.api.nvim_create_augroup('highlight_group', { clear = true })
vim.api.nvim_create_autocmd({ 'VimEnter', 'Colorscheme' }, {
  pattern = "*",
  group = highlight_group,
  command =
  "hi IdeographicSpace ctermbg=DarkGreen guibg=DarkGreen | hi NormalNC guibg=#171717 | hi User1 guifg=#dddddd | hi @variable guifg=Normal"
})
vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter' }, {
  pattern = "*",
  group = highlight_group,
  command = "match IdeographicSpace /　/"
})

vim.api.nvim_create_autocmd('QuitPre', {
  callback = function()
    -- 現在のウィンドウ番号を取得
    local current_win = vim.api.nvim_get_current_win()
    -- すべてのウィンドウをループして調べる
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      -- カレント以外を調査
      if win ~= current_win then
        local buf = vim.api.nvim_win_get_buf(win)
        -- buftypeが空文字（通常のバッファ）があればループ終了
        if vim.bo[buf].buftype == '' then
          return
        end
      end
    end
    -- ここまで来たらカレント以外がすべて特殊ウィンドウということなので
    -- カレント以外をすべて閉じる
    vim.cmd.only({ bang = true })
    -- この後、ウィンドウ1つの状態でquitが実行されるので、Vimが終了する
  end,
  desc = 'Close all special buffers and quit Neovim',
})
