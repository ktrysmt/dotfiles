-- normal mode
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

vim.keymap.set('n', '<Esc><Esc>', '<cmd>nohlsearch<CR><Esc><C-l>', { silent = true })

-- search and replace
vim.keymap.set('n', 'x', '"_x') -- only n, not v
vim.keymap.set('n', 's', '"_s')
vim.keymap.set('n', 'cn', '*N"_cgn')
vim.keymap.set('n', 'cN', '*N"_cgN')
-- vim.keymap.set('n', '<C-g>', "<cmd>echo expand('%:p')<cr>")
vim.keymap.set('n', '<C-g>', function()
  vim.cmd [[
  let @+ =expand('%:p')
  echo expand('%:p')
  ]]
end)
vim.keymap.set('n', '<Leader>p', '"0p', { silent = true })
vim.keymap.set('v', '<Leader>p', '"0p', { silent = true })
vim.keymap.set('n', 'gV', '`[v`]', { silent = true })

-- gh
vim.keymap.set('n', 'gb', function()
  vim.cmd "silent !gh browse %"
end)

-- terminal mode
vim.keymap.set('t', '<C-[>', '<Esc>')
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
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
for i, o in pairs({ j = "<", k = ">" }) do
  vim.keymap.set('n', string.format('<C-w><C-%s>', i), string.format('<C-w>24%s', o), { silent = true })
  vim.keymap.set('t', string.format('<C-w><C-%s>', i), string.format('<cmd>wincmd 24%s<cr>', o), { silent = true })
end

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


-- <C-r>+	クリップボードの中身を挿入する
-- <C-r>%	現在のバッファのファイルパスを挿入する
-- <C-r>/	最後に検索した検索パターンを挿入する
-- <C-r>={expr}<CR>	任意の Vim script の式の評価結果を挿入する

-- :!{cmd}	外部コマンド {cmd} を単に実行する
-- :{range}!{cmd}	{range} で示されたバッファの範囲を標準出力とし、外部コマンド {cmd} を実行した結果で指定範囲を置き換える
-- :r !{cmd}	外部コマンド {cmd} の実行結果をバッファに挿入する
-- :w !{cmd}	バッファの中身を外部コマンド {cmd} の標準入力に流し込んで実行する
