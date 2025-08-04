-- leader
vim.keymap.set('n', "<C-Space>", "<Nop>", { silent = true })
vim.keymap.set('n', "<Space>", "<Nop>", { silent = true })

-- normal mode
vim.keymap.set({ 'n', 'v' }, 'j', 'gj')
vim.keymap.set({ 'n', 'v' }, 'k', 'gk')

vim.keymap.set('n', '<Esc><Esc>', '<cmd>nohlsearch<CR><Esc><C-l>', { silent = true })

-- stay in search
vim.keymap.set('n', 'n', 'n``')
vim.keymap.set('n', 'N', 'N``')
vim.keymap.set('n', '?', '/\\V')

-- search and replace
vim.keymap.set('n', 'x', '"_x') -- only n, not v
vim.keymap.set('n', 's', '"_s')
vim.keymap.set('n', 'cn', '*N"_cgn')
vim.keymap.set('n', 'cN', '*N"_cgN')
vim.keymap.set('n', '<C-g>', function()
  vim.cmd [[
  let @+ =expand('%:p')
  echo expand('%:p')
  ]]
end)
vim.keymap.set('n', '<Leader>p', '"0p', { silent = true })
vim.keymap.set('v', '<Leader>p', '"0p', { silent = true })

-- terminal mode
vim.keymap.set('t', '<c-[><c-[>', '<C-\\><C-n>', { silent = true })
vim.keymap.set('t', '<C-W>w', '<cmd>wincmd w<cr>')
vim.keymap.set('t', '<C-W>k', '<cmd>wincmd k<cr>')
vim.keymap.set('t', '<C-W>j', '<cmd>wincmd j<cr>')
vim.keymap.set('t', '<C-W>h', '<cmd>wincmd h<cr>')
vim.keymap.set('t', '<C-W>l', '<cmd>wincmd l<cr>')
vim.keymap.set('t', '<C-W>W', '<cmd>wincmd W<cr>')
vim.keymap.set('t', '<C-W>K', '<cmd>wincmd K<cr>')
vim.keymap.set('t', '<C-W>J', '<cmd>wincmd J<cr>')
vim.keymap.set('t', '<C-W>H', '<cmd>wincmd H<cr>')
vim.keymap.set('t', '<C-W>L', '<cmd>wincmd L<cr>')
vim.keymap.set('t', '<C-W>x', '<cmd>wincmd x<cr>')

-- insert mode and commandline mode
vim.keymap.set('i', '<C-c>', '<Esc>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('i', '<C-e>', '<C-g>U<End>')
vim.keymap.set('c', '<C-f>', '<Right>', { remap = true }) -- use remapped right key by lexima
vim.keymap.set('i', '<C-f>', '<C-g>U<Right>')
vim.keymap.set({ 'c', 'i' }, '<C-b>', '<Left>')
vim.keymap.set({ 'c', 'i' }, '<C-t>', '<C-o>w')
vim.keymap.set({ 'c', 'i' }, '<C-d>', '<C-o>b')
vim.keymap.set('c', '<C-a>', '<Home>')
local last_press_time = nil
local threshold = 300
vim.keymap.set("i", "<C-a>", function()
  local current_time = vim.fn.reltimefloat(vim.fn.reltime()) * 1000
  if last_press_time and (current_time - last_press_time < threshold) then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<home>', true, true, true), 'n', true)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-o>_', true, true, true), 'n', true)
  end
  last_press_time = current_time
end)

-- quickfix
vim.keymap.set('n', '<Leader>co', '<cmd>copen<cr>', { silent = true })
vim.keymap.set('n', '<Leader>cl', '<cmd>cclose<cr>', { silent = true })
-- vim.keymap.set('n', '<Leader>cc', function()
--   qf_exists = false
--   for _, win in pairs(vim.fn.getwininfo()) do
--     if win["quickfix"] == 1 then
--       qf_exists = true
--     end
--   end
--   if qf_exists == true then
--     vim.cmd "cclose"
--     return
--   else
--     vim.cmd "copen"
--     vim.g.qf_exists = true
--     return
--   end
-- end
-- , { silent = true })

-- tab jump
for i = 1, 9 do
  vim.keymap.set('n', string.format('t%d', i), string.format('%dgt', i), { silent = true })
end

-- window jump
for i = 1, 9 do
  vim.keymap.set('n', string.format('<C-w>%d', i), string.format('<C-w>%dw', i), { silent = true })
  vim.keymap.set('t', string.format('<C-w>%d', i), string.format('<cmd>wincmd %dw<cr>', i), { silent = true })
end

-- resize window
-- for i, o in pairs({ j = "<", k = ">" }) do
--   vim.keymap.set('n', string.format('<C-w><C-%s>', i), string.format('<C-w>24%s', o), { silent = true })
--   vim.keymap.set('t', string.format('<C-w><C-%s>', i), string.format('<cmd>wincmd 24%s<cr>', o), { silent = true })
-- end

-- move
-- vim.keymap.set("n", "<C-j>", '"zdd"zp')
-- vim.keymap.set("n", "<C-k>", '"zdd<Up>"zP')
vim.keymap.set("v", "<C-j>", '"zx"zp`[V`]')
vim.keymap.set("v", "<C-k>", '"zx<Up>"zP`[V`]')

-- a to 2i
for _, quote in ipairs({ '"', "'", "`" }) do
  vim.keymap.set({ "x", "o" }, "a" .. quote, "2i" .. quote)
end

-- macro shortcut
vim.keymap.set('n', '<Leader>q', '@q')

-- replace a" to 2i" https://zenn.dev/vim_jp/articles/2024-06-05-vim-middle-class-features
for _, quote in ipairs({ '"', "'", "`" }) do
  vim.keymap.set({ "x", "o" }, "a" .. quote, "2i" .. quote)
end

-- <C-r>+	クリップボードの中身を挿入する
-- <C-r>%	現在のバッファのファイルパスを挿入する
-- <C-r>/	最後に検索した検索パターンを挿入する
-- <C-r>={expr}<CR>	任意の Vim script の式の評価結果を挿入する
--
-- :!{cmd}	外部コマンド {cmd} を単に実行する
-- :{range}!{cmd}	{range} で示されたバッファの範囲を標準出力とし、外部コマンド {cmd} を実行した結果で指定範囲を置き換える
-- :r !{cmd}	外部コマンド {cmd} の実行結果をバッファに挿入する
-- :w !{cmd}	バッファの中身を外部コマンド {cmd} の標準入力に流し込んで実行する
--
-- Visualモードで数字の列を矩形選択→g<C-a>で連番作成
-- func(a1,|a2,a3)のときct)でfunc(a1,)でインサートモード

--
-- upper/lower toggle in insert mode
--
vim.keymap.set("i", "<C-l>",
  function()
    local word = vim.fn.expand('<cword>')
    if word == "" then
      return ""
    end
    local pos = vim.fn.getpos('.')
    if word == word:upper() then
      return "<C-o>diw" ..
          word:lower() ..
          "<C-o>:call setpos('.', [" .. pos[1] .. "," .. pos[2] .. "," .. pos[3] .. "," .. pos[4] .. "])<CR>"
    else
      return "<C-o>diw" ..
          word:upper() ..
          "<C-o>:call setpos('.', [" .. pos[1] .. "," .. pos[2] .. "," .. pos[3] .. "," .. pos[4] .. "])<CR>"
    end
  end,
  { expr = true }
)

--
-- window resize mode
--
local win_resize_cmd_dict = {}
local count = 5
local function has_edge(direct)
  if direct == 'left' then
    return vim.fn.winnr('h') ~= vim.fn.winnr()
  elseif direct == 'down' then
    return vim.fn.winnr('j') ~= vim.fn.winnr()
  elseif direct == 'up' then
    return vim.fn.winnr('k') ~= vim.fn.winnr()
  elseif direct == 'right' then
    return vim.fn.winnr('l') ~= vim.fn.winnr()
  end
  error('invalid direct')
end
local function win_resize_count_cmd_with_update(direct)
  local signs = { left = '-', down = '+', up = '-', right = '+' }
  if has_edge('left') and not has_edge('right') then
    signs.left = '+'
    signs.right = '-'
  end
  if has_edge('up') and not has_edge('down') then
    signs.up = '+'
    signs.down = '-'
  end
  win_resize_cmd_dict = {
    left = '<Cmd>vertical resize ' .. signs.left .. count .. '<CR>',
    right = '<Cmd>vertical resize ' .. signs.right .. count .. '<CR>',
    down = '<Cmd>resize ' .. signs.down .. count .. '<CR>',
    up = '<Cmd>resize ' .. signs.up .. count .. '<CR>',
  }
  if direct == 'left' or direct == 'right' then
    return '<Cmd>vertical resize ' .. signs[direct] .. count .. '<CR>'
  else
    return '<Cmd>resize ' .. signs[direct] .. count .. '<CR>'
  end
end
local function win_resize_cmd(direct)
  return win_resize_cmd_dict[direct] or ''
end
vim.keymap.set('n', '<Plug>(window-resize-mode)', '<Nop>')
vim.keymap.set('n', '<C-w>-', function()
  local cmd = win_resize_count_cmd_with_update('down')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd .. '<Plug>(window-resize-mode)', true, true, true), 'n', true)
end)
vim.keymap.set('n', '<C-w>+', function()
  local cmd = win_resize_count_cmd_with_update('up')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd .. '<Plug>(window-resize-mode)', true, true, true), 'n', true)
end)
vim.keymap.set('n', '<C-w>>', function()
  local cmd = win_resize_count_cmd_with_update('right')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd .. '<Plug>(window-resize-mode)', true, true, true), 'n', true)
end)
vim.keymap.set('n', '<C-w><', function()
  local cmd = win_resize_count_cmd_with_update('left')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd .. '<Plug>(window-resize-mode)', true, true, true), 'n', true)
end)
vim.keymap.set('n', '<Plug>(window-resize-mode)-', function()
  local cmd = win_resize_cmd('down')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd .. '<Plug>(window-resize-mode)', true, true, true), 'n', true)
end)
vim.keymap.set('n', '<Plug>(window-resize-mode)+', function()
  local cmd = win_resize_cmd('up')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd .. '<Plug>(window-resize-mode)', true, true, true), 'n', true)
end)
vim.keymap.set('n', '<Plug>(window-resize-mode)>', function()
  local cmd = win_resize_cmd('right')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd .. '<Plug>(window-resize-mode)', true, true, true), 'n', true)
end)
vim.keymap.set('n', '<Plug>(window-resize-mode)<', function()
  local cmd = win_resize_cmd('left')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd .. '<Plug>(window-resize-mode)', true, true, true), 'n', true)
end)
